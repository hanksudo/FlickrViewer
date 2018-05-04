//
//  ViewController.swift
//  FlickrViewer
//
//  Created by Hank Wang on 2018/5/4.
//  Copyright © 2018 hanksudo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var grabNewImageButton: UIButton!
    
    func displayError(_ error: String) {
        print(error)
        DispatchQueue.main.async {
            self.grabNewImageButton.isEnabled = true
        }
    }
    
    fileprivate func getRandomImage() {
        grabNewImageButton.isEnabled = false
        let someParameters = [
            "method": "flickr.galleries.getPhotos",
            "api_key": "68da3a81a95b2832e0bee9b8221aa7c9",  // tmp API key
            "gallery_id": 72157695356899955,
            "format": "json",
            "extras": "url_m",
            "nojsoncallback": 1
            ] as [String : Any]
        
        let baseURL = "https://api.flickr.com/services/rest/"
        let urlString = baseURL + escapedParameters(someParameters as [String : AnyObject])
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard (error == nil) else {
                print("There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            var parsedResult: [String: AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let stat = parsedResult["stat"] as? String, stat == "ok" else {
                print(parsedResult)
                return
            }
            
            guard let photosDict = parsedResult["photos"] as? [String: AnyObject],
                let photosArray = photosDict["photo"] as? [[String: AnyObject]] else
            {
                print("Missing key photos or photo", parsedResult)
                return
            }
            
            let randomIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
            let photoDict = photosArray[randomIndex] as [String: AnyObject]
            let title = photoDict["title"] as? String
            
            guard let imageUrlString = photoDict["url_m"] as? String else {
                print("Missing key url_m")
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
                print("Image does net exists at \(String(describing: imageURL))")
            }
        }
        
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getRandomImage()
    }

    @IBAction func grabNewImage(_ sender: Any) {
        getRandomImage()
    }
    
    func escapedParameters(_ parameters: [String: AnyObject]) -> String {
        if parameters.isEmpty { return "" }
        
        var keyValuePairs = [String]()
        
        for (key, value) in parameters {
            // make sure that it is a string value
            let stringValue = "\(value)"
            
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            keyValuePairs.append(key + "=" + "\(escapedValue!)")
        }
        
        return "?\(keyValuePairs.joined(separator: "&"))"
    }


}

