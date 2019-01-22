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
        return displayNamesForKinds[kind] ?? kind
    }
    
    private let displayNamesForKinds = [
        "album" : NSLocalizedString("Album", comment:"Localized kind: Album"),
        "audiobook": NSLocalizedString("Audio Book", comment:"Localized kind: Audio Book"),
        "book": NSLocalizedString("Book", comment:"Localized kind: Book"),
        "ebook": NSLocalizedString("E-Book", comment:"Localized kind: E-Book"),
        "music-video": NSLocalizedString("Music Video", comment:"Localized kind: Music Video"),
        "feature-movie": NSLocalizedString("Movie", comment:"Localized kind: Movie"),
        "podcast": NSLocalizedString("Podcast", comment:"Localized kind: Podcast"),
        "software": NSLocalizedString("App", comment:"Localized kind: App"),
        "song": NSLocalizedString("Song", comment:"Localized kind: Song"),
        "tv-episode": NSLocalizedString("TV Episode", comment:"Localized kind: TV Episode")
    
    ]
    
}

func < (lhs:SearchResult, rhs:SearchResult)->Bool {
    return lhs.name.localizedCompare(rhs.name) == ComparisonResult.orderedAscending
}
