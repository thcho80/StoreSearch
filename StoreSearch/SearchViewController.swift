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
            
            if let jsonString = performStoreRequestWithUrl(url: url){
                if let dictionary = parseJSON(jsonString: jsonString){
                    searchResults = parseDictionary(dictionary: dictionary)
                    searchResults.sort(by: {result1, result2 in
                        return result1.name.localizedStandardCompare(result2.name) == ComparisonResult.orderedAscending
                    })
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
    
    func kindForDisplay(kind:String)->String {
        switch kind {
        case "album" : return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "music-video": return "Music Video"
        case "feature-movie": return "Movie"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: return kind
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
            
            if searchResult.artistName.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            } else {
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(kind: searchResult.kind))
            }
            return cell
        }
    }
    
    
}
