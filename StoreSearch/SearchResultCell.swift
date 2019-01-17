//
//  SearchResultCellTableViewCell.swift
//  StoreSearch
//
//  Created by human on 2019. 1. 9..
//  Copyright © 2019년 com.humantrion. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var nameLabel:UILabel!
    @IBOutlet weak var artistNameLabel:UILabel!
    @IBOutlet weak var artworkImageView:UIImageView!
    
    var downloadTask:URLSessionDownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadTask?.cancel()
        downloadTask = nil
        nameLabel.text = nil
        artistNameLabel.text = nil
        artworkImageView.image = nil
    }
    
    func configureForSearchResult(searchResult:SearchResult){
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = "UnKnown"
        } else {
            artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, searchResult.kindForDisplay())
        }
        
        artworkImageView.image = UIImage(named: "PlaceHolder")
        if let url = URL(string: searchResult.artworkURL60) {
            downloadTask = artworkImageView.loadImageWithUrl(url: url)
        }
    }
    
    

}
