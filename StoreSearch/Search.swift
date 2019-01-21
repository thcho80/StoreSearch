import Foundation

class Search {
    let iTunesUrl = "http://itunes.apple.com"
    
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    private var dataTask:URLSessionDataTask? = nil
    
    typealias SearchComplete = (Bool)->Void
    
    func performSearchForText(text:String, category:Int, completion:@escaping SearchComplete){
        if !text.isEmpty {
            dataTask?.cancel()
            
            isLoading = true
            hasSearched = true
            searchResults = [SearchResult]()
            
            let url = urlWithSearchText(searchText: text, category: category)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
                var success = false
               
                if let error = error {
                    print("*** Error occured: \(error)")
                    return
                } else if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if let dictionary = self.parseJSON(data: data! as NSData){
                            self.searchResults = self.parseDictionary(dictionary: dictionary)
                            self.searchResults.sort(by: <)
                            print("Success!")
                            self.isLoading = false
                            success = true
                        }
                    }
                }
                
                if !success {
                    self.hasSearched = false
                    self.isLoading = false
                }
                
Utils.isMainThread()
                DispatchQueue.main.async {
Utils.isMainThread()
                    completion(success)
                }

            })
            dataTask?.resume()
        }
    }
    
    private func urlWithSearchText(searchText:String, category:Int)->URL {
        var entityName:String
        switch category {
        case 1: entityName = "musicTrack"
        case 2: entityName = "software"
        case 3: entityName = "ebook"
        default : entityName = ""
        }
        
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let urlString = String(format: "\(iTunesUrl)/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        let url = URL(string: urlString)
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
