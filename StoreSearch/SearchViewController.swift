//
//  ViewController.swift
//  StoreSearch
//
//  Created by human on 2019. 1. 7..
//  Copyright © 2019년 com.humantrion. All rights reserved.
//

import UIKit

struct TableViewCellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
}

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 56, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        searchBar.becomeFirstResponder()
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !(searchBar.text!.isEmpty) {
            searchBar.resignFirstResponder()
            
            searchResults = [SearchResult]()
            hasSearched = true
            
            let url = urlWithSearchText(searchText: searchBar.text!)
            print(url)
            if let jsonString = performStoreRequestWithUrl(url: url){
                if let dictionary = parseJSON(jsonString: jsonString){
//                    print("Dictionary: \(dictionary)")
                    parseDictionary(dictionary: dictionary)
                    tableView.reloadData()
                    return
                }
            }
            showNetworkError()
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func urlWithSearchText(searchText:String)->NSURL {
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let urlString = String(format: "http://itunes.apple.com/search?term=%@", escapedSearchText)
        let url = NSURL(string: urlString)
        return url!
    }
    
    func performStoreRequestWithUrl(url:NSURL)->String? {
        do {
            let resultString = try String(contentsOf: url as URL, encoding: String.Encoding.utf8)
            return resultString
        } catch {
            print("Error create resultString \(error)")
        }
        return nil
    }
    
    func parseJSON(jsonString:String)->[String:AnyObject]? {
        if let data = jsonString.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                return json as? [String : AnyObject]
            } catch {
                print("parse JSON error \(error)")
            }
        }
        return nil
    }
    
    func showNetworkError(){
        let alert = UIAlertController(title: "Whoops.."
            , message: "There was an error reading from the iTynes Store. Please try again"
            , preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func parseDictionary(dictionary:[String:AnyObject]) {
        if let array:AnyObject = dictionary["results"] {
            for resultDict in array as! [AnyObject] {
                if let resultDict = resultDict as? [String:AnyObject] {
                    if let wrapperType = resultDict["wrapperType"] as? NSString {
                        if let kind = resultDict["kind"] as? NSString {
                            print("wrapperType: \(wrapperType), kind:\(kind)")
                        }
                    }
                } else {
                    print("expected a dictionary")
                }
            }
        } else {
            print("expected 'results' array")
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel!.text = searchResult.name
            cell.artistNameLabel!.text = searchResult.artistName
            
            return cell
        }
    }
}
