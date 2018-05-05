//
//  RandomPhotoViewController.swift
//  FlickrViewer
//
//  Created by Hank Wang on 2018/5/4.
//  Copyright © 2018 hanksudo. All rights reserved.
//

import UIKit

class RandomPhotoViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var grabNewImageButton: UIButton!
    

    fileprivate func getRandomImage() {
    
        grabNewImageButton.isEnabled = false
        
        FlickrAPI.getPhotos(72157695356899955) { (photosArray, error) in
            func displayError(_ error: String) {
                print(error)
                DispatchQueue.main.async {
                    self.grabNewImageButton.isEnabled = true
                }
            }
            
            guard (error == nil) else {
                displayError(error!.message)
                return
            }
            
            let randomIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
            let photoDict = photosArray[randomIndex] as [String: AnyObject]
            let title = photoDict["title"] as? String
            
            guard let imageUrlString = photoDict["url_m"] as? String else {
                displayError("Missing key url_m")
                return
            }
            
            let imageURL = URL(string: imageUrlString)
            if let imageData = try? Data(contentsOf: imageURL!) {
                DispatchQueue.main.async {
                    self.titleLabel.text = title ?? "(Untitled)"
                    self.imageView.image = UIImage(data: imageData)
                    self.grabNewImageButton.isEnabled = true
                }
            } else {
                displayError("Image does net exists at \(String(describing: imageURL))")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRandomImage()
    }

    @IBAction func grabNewImage(_ sender: Any) {
        getRandomImage()
    }
}

