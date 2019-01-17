import Foundation

class SearchResult {
    var name = ""
    var artistName = ""
    var artworkURL60 = ""
    var artworkURL100 = ""
    var storeURL = ""
    var kind = ""
    var currency = ""
    var price = 0.0
    var genre = ""
    
    //MARK: - Private Method
    func kindForDisplay()->String {
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

func < (lhs:SearchResult, rhs:SearchResult)->Bool {
    return lhs.name.localizedCompare(rhs.name) == ComparisonResult.orderedAscending
}
