import Foundation
import UIKit

class Search {
    let iTunesUrl = "http://itunes.apple.com"
   
    private var dataTask:URLSessionDataTask? = nil
    
    typealias SearchComplete = (Bool)->Void
    
    enum Category:Int {
        case all = 0
        case music = 1
        case software = 2
        case ebook = 3
        
        var entityName:String {
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebook: return "ebook"
            }
        }
    }
    
    enum State {
        case notSearchYet
        case loading
        case noResults
        case results([SearchResult])
    }
    
    private(set) var state:State = .notSearchYet
    
    func performSearchForText(text:String, category:Category, completion:@escaping SearchComplete){
        if !text.isEmpty {
            dataTask?.cancel()
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            state = .loading
            let url = urlWithSearchText(searchText: text, category: category)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
                self.state = .notSearchYet
                var success = false
               
                if let error = error {
                    print("*** Error occured: \(error)")
                    return
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let dictionary = self.parseJSON(data: data! as NSData){
                            var searchResults = self.parseDictionary(dictionary: dictionary)
                            if searchResults.isEmpty {
                                self.state = .noResults
                            } else {
                                searchResults.sort(by: <)
                                self.state = .results(searchResults)
                            }
                            success = true
                        }
                    }
                }
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    completion(success)
                }

            })
            dataTask?.resume()
        }
    }
    
    private func urlWithSearchText(searchText:String, category:Category)->URL {
      
        let locale = Locale.autoupdatingCurrent
//        let lang = locale.localizedString(forIdentifier: locale.identifier)!
        let countryCode = locale.regionCode ?? "en_US"
        let kind = category.entityName
        let encodedText = searchText.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let urlString = "https://itunes.apple.com/search?" +
                        "term=\(encodedText)&limit=200&entity=\(kind)" +
                        "&country=\(countryCode)"
//                        + "&lang=\(lang)"
        
        let url = URL(string: urlString)
        print("URL: \(url!)")
        return url!
        
    }
    
    private func parseJSON(data:NSData)->[String:AnyObject]? {
        do {
            let json = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions(rawValue: 0))
            return json as? [String : AnyObject]
        } catch {
            print("parse JSON error \(error)")
        }
        
        return nil
    }
    
    private func parseDictionary(dictionary:[String:AnyObject])->[SearchResult] {
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
    
    private func parseTrack(dictionary:[String:AnyObject])->SearchResult {
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
    
    private func parseAudioBook(dictionary:[String:AnyObject])->SearchResult {
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
    
    private func parseSoftware(dictionary:[String:AnyObject])->SearchResult {
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
    
    private func parseEBook(dictionary:[String:AnyObject])->SearchResult {
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
}
