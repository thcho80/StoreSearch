//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by human on 2019. 1. 18..
//  Copyright © 2019년 com.humantrion. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var pageControl:UIPageControl!

    var search:Search!
    
    private var firstTime = true
    private var downloadTasks = [URLSessionDownloadTask]()
    deinit {
        print("DeInit \(self)")
        
        for task in downloadTasks {
            task.cancel()
        }
    }

    @IBAction func pageChanged(sender:UIPageControl){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
        }, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
        pageControl.numberOfPages = 0
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        pageControl.frame = CGRect(x: 0, y: view.frame.size.height - pageControl.frame.size.height, width: view.frame.size.width, height: pageControl.frame.size.height)
        
        if firstTime {
            firstTime = false
            
            switch search.state {
            case .notSearchYet:
                break
            case .loading:
                showSpinner()
                break
            case .noResults:
                showNothingFoundLabel()
                break
            case .results(let list):
                tileButtons(searchResults: list)
            }
        }
    }
    
    private func tileButtons(searchResults:[SearchResult]){
        //calcute item size
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth:CGFloat = 96
        var itemHeight:CGFloat = 88
        var marginX:CGFloat = 0
        var marginY:CGFloat = 20
        
        let scrollViewWidth = scrollView.bounds.size.width
        
        switch scrollViewWidth {
        case 568:
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
        case 667:
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
        case 736:
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
        default:
            break
        }
        
        //button size
        let buttonWidth:CGFloat = 82
        let buttonHeight:CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddingVert = (itemHeight - buttonHeight) / 2
        
        //create Buttons
        var row = 0
        var column = 0
        var x = marginX
        
        for(index, searchResult) in searchResults.enumerated() {
            let button = UIButton.init(type: .custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            downloadImageForSearchResult(searchResult: searchResult, andPlaceOnButton: button)
            button.frame = CGRect(x: x+paddingHorz, y: marginY + CGFloat(row)*itemHeight + paddingVert, width: buttonWidth, height: buttonHeight)
            button.tag = 2000 + index
            button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
            scrollView.addSubview(button)
            
            row += 1
            
            if row == rowsPerPage {
                row = 0
                column += 1
                x += itemWidth
                
                if column == columnsPerPage {
                    column = 0
                    x += marginX * 2
                }
            }
        }
        
        //paging
        let buttonPerPage = columnsPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonPerPage
        
        scrollView.contentSize = CGSize(width: CGFloat(numPages)*scrollViewWidth, height: scrollView.bounds.size.height) // 전체 스크롤화면의 크기
        
        print("Number of Pages: \(numPages)")
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
        
    }
    
    @objc private func buttonPressed(sender:UIButton){
        performSegue(withIdentifier: "ShowDetail", sender: sender)
    }
    
    private func showNothingFoundLabel(){
        let label = UILabel(frame: CGRect.zero)
        label.text = "Nothing Found"
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        
        label.sizeToFit()
        
        var rect = label.frame
        rect.size.width = ceil(rect.size.width / 2) * 2
        rect.size.height = ceil(rect.size.height / 2) * 2
        label.frame = rect
        label.center = CGPoint(x: scrollView.bounds.midX, y: scrollView.bounds.midY)
        
        view.addSubview(label)
    }
    
    private func downloadImageForSearchResult(searchResult:SearchResult, andPlaceOnButton button:UIButton) {
        
        if let url = URL(string: searchResult.artworkURL60){
            let session = URLSession.shared
            let downloadTask = session.downloadTask(with: url, completionHandler: {
                [weak button] url, response, error in
                if error == nil && url != nil {
                    do {
                        let data = try Data(contentsOf: url!)
                        let image = UIImage(data: data)
                        
                        DispatchQueue.main.async {
                            if let button = button {
                                button.setImage(image, for: .normal)
                            }
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                }
            })
            downloadTask.resume()
            downloadTasks.append(downloadTask)
        }
    }
    
    func searchResultsReceived(){
        hideSpinner()
        
        switch search.state {
        case .notSearchYet, .loading:
            break
        case .noResults:
            showNothingFoundLabel()
        case .results(let list):
            tileButtons(searchResults: list)            
        }
    }
    
    private func showSpinner() {
        let spinner = UIActivityIndicatorView(style: .white)
        spinner.center = CGPoint(x: scrollView.bounds.midX + 0.5, y: scrollView.bounds.midY + 0.5)
        spinner.tag = 1000
        
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    private func hideSpinner(){
        view.viewWithTag(1000)?.removeFromSuperview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            switch search.state{
            case .results(let list):
                let detailViewController = segue.destination as! DetailViewController
                let button = sender as! UIButton
                let searchResult = list[button.tag - 2000]
                detailViewController.searchResult = searchResult
            case .notSearchYet:
                return
            case .loading:
                return
            case .noResults:
                return
            }
        }
    }

}

extension LandscapeViewController:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let currentPage = Int((scrollView.contentOffset.x + width/2) / width)
        pageControl.currentPage = currentPage
    }
}
