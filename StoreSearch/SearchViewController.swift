//
//  ViewController.swift
//  StoreSearch
//
//  Created by human on 2019. 1. 7..
//  Copyright © 2019년 com.humantrion. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    let iTunesUrl = "http://itunes.apple.com"
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    var dataTask:URLSessionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 95, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        searchBar.becomeFirstResponder()
    }
    
    // MARK:- Private Methods
    
    @IBAction func segmentChange(_ sender: UISegmentedControl) {
        print("Segment Change: \(sender.selectedSegmentIndex)")
        performSeach()
    }
    
    
    func urlWithSearchText(searchText:String, category:Int)->NSURL {
        var entityName:String
        switch category {
        case 1: entityName = "musicTrack"
        case 2: entityName = "software"
        case 3: entityName = "ebook"
        default : entityName = ""
        }
        
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let urlString = String(format: "\(iTunesUrl)/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        let url = NSURL(string: urlString)
        return url!
    }
    
    func parseJSON(data:NSData)->[String:AnyObject]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))
            return json as? [String : AnyObject]
        } catch {
            print("parse JSON error \(error)")
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
    
    func parseDictionary(dictionary:[String:AnyObject])->[SearchResult] {
        var searchResults = [SearchResult]()
        
        if let array:AnyObject = dictionary["results"] {
            for resultDict in array as! [AnyObject] {
                if let resultDict = resultDict as? [String:AnyObject] {
                    var searchResult:SearchResult?
                    
                    if let wrapperType = resultDict["wrapperType"] as? NSString {
                        switch wrapperType {
                        case "track":
                            searchResult = parseTrack(dictionary: resultDict)
                        case "audiobook":
                            searchResult = parseAudioBook(dictionary: resultDict)
                        case "software":
                            searchResult = parseSoftware(dictionary: resultDict)
                        default:
                            break
                        }
                    } else if let kind = resultDict["kind"] as? NSString {
                        if kind == "ebook" {
                            searchResult = parseEBook(dictionary: resultDict)
                        }
                    }
                    
                    if let result = searchResult {
                        searchResults.append(result)
                    }
                } else {
                    print("expected a dictionary")
                }
            }
        } else {
            print("expected 'results' array")
        }
        return searchResults
    }
    
    func parseTrack(dictionary:[String:AnyObject])->SearchResult {
        let searchResult = SearchResult()
        searchResult.name = (dictionary["trackName"] as! NSString) as String
        searchResult.artistName = (dictionary["artistName"] as! NSString) as String
        searchResult.artworkURL60 = (dictionary["artworkUrl60"] as! NSString) as String
        searchResult.artworkURL100 = (dictionary["artworkUrl100"] as! NSString) as String
        searchResult.storeURL = (dictionary["trackViewUrl"] as! NSString) as String
        searchResult.kind = (dictionary["kind"] as! NSString) as String
        searchResult.currency = ((dictionary["currency"] as! NSString) as String)
        
        if let price = dictionary["trackPrice"] as? NSNumber {
            searchResult.price = Double(truncating: price)
        }
        if let genre = dictionary["primaryGenreName"] as? NSString {
            searchResult.genre = genre as String
        }
        return searchResult
    }
    
    func parseAudioBook(dictionary:[String:AnyObject])->SearchResult {
        let searchResult = SearchResult()
        searchResult.name = (dictionary["collectionName"] as! NSString) as String
        searchResult.artistName = (dictionary["artistName"] as! NSString) as String
        searchResult.artworkURL60 = (dictionary["artworkUrl60"] as! NSString) as String
        searchResult.artworkURL100 = (dictionary["artworkUrl100"] as! NSString) as String
        searchResult.storeURL = (dictionary["collectionViewUrl"] as! NSString) as String
        searchResult.kind = "audiobook"
        searchResult.currency = ((dictionary["currency"] as! NSString) as String)
        
        if let price = dictionary["collectionPrice"] as? NSNumber {
            searchResult.price = Double(truncating: price)
        }
        if let genre = dictionary["primaryGenreName"] as? NSString {
            searchResult.genre = genre as String
        }
        return searchResult
    }
    
    func parseSoftware(dictionary:[String:AnyObject])->SearchResult {
        let searchResult = SearchResult()
        searchResult.name = (dictionary["trackName"] as! NSString) as String
        searchResult.artistName = (dictionary["artistName"] as! NSString) as String
        searchResult.artworkURL60 = (dictionary["artworkUrl60"] as! NSString) as String
        searchResult.artworkURL100 = (dictionary["artworkUrl100"] as! NSString) as String
        searchResult.storeURL = (dictionary["trackViewUrl"] as! NSString) as String
        searchResult.kind = (dictionary["kind"] as! NSString) as String
        searchResult.currency = ((dictionary["currency"] as! NSString) as String)
        
        if let price = dictionary["price"] as? NSNumber {
            searchResult.price = Double(truncating: price)
        }
        if let genre = dictionary["primaryGenreName"] as? NSString {
            searchResult.genre = genre as String
        }
        return searchResult
    }
    
    func parseEBook(dictionary:[String:AnyObject])->SearchResult {
        let searchResult = SearchResult()
        searchResult.name = (dictionary["trackName"] as! NSString) as String
        searchResult.artistName = (dictionary["artistName"] as! NSString) as String
        searchResult.artworkURL60 = (dictionary["artworkUrl60"] as! NSString) as String
        searchResult.artworkURL100 = (dictionary["artworkUrl100"] as! NSString) as String
        searchResult.storeURL = (dictionary["trackViewUrl"] as! NSString) as String
        searchResult.kind = (dictionary["kind"] as! NSString) as String
        searchResult.currency = ((dictionary["currency"] as! NSString) as String)
        
        if let price = dictionary["price"] as? NSNumber {
            searchResult.price = Double(truncating: price)
        }
        if let genres:[String] = dictionary["genres"] as! [String]{
            searchResult.genre = genres.joined(separator: ",")
        }
        return searchResult
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! NSIndexPath
            let searchResult = searchResults[indexPath.row]
            detailViewController.searchResult = searchResult
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSeach()
    }
    func performSeach() {
        if !(searchBar.text!.isEmpty) {
            searchBar.resignFirstResponder()
            
            isLoading = true //indicator spinning start
            tableView.reloadData()
            
            searchResults = [SearchResult]()
            hasSearched = true
            
            let url = self.urlWithSearchText(searchText: searchBar.text!, category: segmentControl.selectedSegmentIndex )
            let session = URLSession.shared
            
            dataTask?.cancel()
            
            dataTask = session.dataTask(with: url as URL, completionHandler: {data, response, error in
                if let error = error {
                    print("Failure! \(error)")
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        print("Success! \(String(describing: data))")
                        if let dictionary = self.parseJSON(data: data! as NSData) {
                            self.searchResults = self.parseDictionary(dictionary: dictionary)
                            self.searchResults.sort(by: <)
                            DispatchQueue.main.async {
                                self.isLoading = false                  // indicator spinning stop
                                self.tableView.reloadData()
                                print("*** DONE")
                            }
                            return
                        }
                    } else {
                        print("Failure! \(String(describing: response))")
                        DispatchQueue.main.async {
                            self.hasSearched = false
                            self.isLoading = false
                            self.tableView.reloadData()
                            self.showNetworkError()
                            print("*** Failure!")
                        }
                    }
                }
            })
            dataTask?.resume()
            
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0  || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading {
            return 1
        }else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
        } else if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            let searchResult = searchResults[indexPath.row]
            cell.configureForSearchResult(searchResult: searchResult)
            
            return cell
        }
    }
    
    
}
