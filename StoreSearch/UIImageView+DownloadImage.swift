//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by human on 2019. 1. 15..
//  Copyright © 2019년 com.humantrion. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImageWithUrl(url:URL)->URLSessionDownloadTask {
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: url, completionHandler: {
            [weak self] url, response, error in
            if error == nil && url != nil {
                do {
                    let data = try Data(contentsOf: url!)
                    let image = UIImage(data: data)
                    
                    DispatchQueue.main.async {
                        if let strongSelf = self{
                            strongSelf.image = image
                        }
                    }
                } catch {
                    print("Error: \(error)")
                }
            }
        })
        downloadTask.resume()
        return downloadTask
    }
}

