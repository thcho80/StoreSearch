//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by human on 2019. 1. 16..
//  Copyright © 2019년 com.humantrion. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    var searchResult:SearchResult!
    var downloadTask:URLSessionDownloadTask?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    deinit {
        print("deinit \(self)")
        downloadTask?.cancel()
    }
    
    // MARK: - Private Function
    override func viewDidLoad() {
        super.viewDidLoad()
        view.tintColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 1)
        popupView.layer.cornerRadius = 10
        
        let gestureRecogniger = UITapGestureRecognizer(target: self, action: #selector(self.close(_:)))
        gestureRecogniger.cancelsTouchesInView = false
        gestureRecogniger.delegate = self
        view.addGestureRecognizer(gestureRecogniger)
        
        if searchResult != nil {
            updateUI()
        }
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore() {
        if let url = URL(string: searchResult.storeURL) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(url): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(url): \(success)")
            }
        }
        
        
    }
    
    func updateUI() {
        nameLabel.text = searchResult.name
        
        if searchResult.artistName.isEmpty {
            artistNameLabel.text = "UnKnown"
        } else {
            artistNameLabel.text = searchResult.artistName
        }
        
        kindLabel.text = searchResult.kindForDisplay()
        genreLabel.text = searchResult.genre
        
        //price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        
        var priceText:String
        if searchResult.price == 0 {
            priceText = "Free"
        } else if let text = formatter.string(for: searchResult.price) {
            priceText = text
        } else {
            priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
        
        //Image
        if let url = URL(string: searchResult.artworkURL100) {
            downloadTask = artworkImageView.loadImageWithUrl(url: url)
        }
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController.init(presentedViewController: presented, presenting: presenting)
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        return (touch.view === view)
    }
}
