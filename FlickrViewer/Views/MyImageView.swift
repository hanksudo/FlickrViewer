//
//  MyImageView.swift
//  FlickrViewer
//
//  Created by Hank Wang on 2020/09/30.
//  Copyright © 2020 hanksudo. All rights reserved.
//

import UIKit

class MyImageView: UIImageView {
    
    var task: URLSessionDataTask?
    
    func loadFromURL(_ urlString: String) {
        self.clearTask()
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                return
            }
            
            guard (error == nil) else {
                return
            }
            
            let imageToCache = UIImage(data: data!)
            imageCache.setObject(imageToCache!, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                self.image = imageToCache
                self.clearTask()
            }
        })
        task!.resume()
    }
    
    func clearTask() {
        if self.task != nil {
            self.task!.cancel()
            self.task = nil
        }
    }
}
