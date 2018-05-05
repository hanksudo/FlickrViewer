//
//  SearchPhotosCollectionViewController.swift
//  FlickrViewer
//
//  Created by Hank Wang on 2018/5/5.
//  Copyright © 2018 hanksudo. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let ImageViewTag = 1

class SearchPhotosCollectionViewController: UICollectionViewController {

    var photos = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(SearchPhotosCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        let minimumInterItemSpacing: CGFloat = 3
        let minimumLineSpacing: CGFloat = 3
        let numberOfColumns: CGFloat = 3
        
        let width = ((collectionView?.frame.width)! - minimumInterItemSpacing - minimumLineSpacing) / numberOfColumns
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = minimumInterItemSpacing
        layout.minimumLineSpacing = minimumLineSpacing
        
        layout.itemSize = CGSize(width: width, height: width)

        FlickrAPI.searchPhotos(text: "Taiwan") { (photosArray, error) in
            self.photos = photosArray
            print(self.photos.count)
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SearchPhotosCollectionViewCell
      
        let photoDict = photos[(indexPath as NSIndexPath).row]
        
        if let imageUrlString = photoDict["url_m"] as? String
        {
            cell.imageView.loadFromURL(imageUrlString)
        }
        
        return cell
    }
}

let imageCache = NSCache<NSString, UIImage>()

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
