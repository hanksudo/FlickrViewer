//
//  FlickrAPI.swift
//  FlickrViewer
//
//  Created by Hank Wang on 2018/5/5.
//  Copyright © 2018 hanksudo. All rights reserved.
//

import UIKit

struct Error {
    var message: String
}

class FlickrAPI {
    
    static let baseURL = "https://api.flickr.com/services/rest/"
    static let baseParams = [
        // https://www.flickr.com/services/apps/create/apply/?
        "api_key": "",
        "extras": "url_m",
        "format": "json",
        "nojsoncallback": 1
        ] as [String : Any]
    
    class func prepareURL(_ params: [String: Any]) -> URL {
        let urlString = baseURL + escapedParameters(params as [String : AnyObject])
        return URL(string: urlString)!
    }
    
    class func searchPhotos(text: String, completionHandler: @escaping ([[String: AnyObject]], Error?) -> Void) {
        var params = baseParams
        params["method"] = "flickr.photos.search"
        params["in_gallery"] = 1
        params["text"] = text
        
        func handleError(_ message: String) {
            completionHandler([[:]], Error(message: message))
        }
        
        let task = URLSession.shared.dataTask(with: prepareURL(params)) { (data, response, error) in
            guard (error == nil) else {
                handleError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let data = data else {
                handleError("No data was returned by the request!")
                return
            }
            
            var parsedResult: [String: AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            } catch {
                handleError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let stat = parsedResult["stat"] as? String, stat == "ok" else {
                handleError("Stat fail '\(parsedResult)'")
                return
            }
            
            guard let photosDict = parsedResult["photos"] as? [String: AnyObject],
                let photosArray = photosDict["photo"] as? [[String: AnyObject]] else
            {
                handleError("Missing key photos or photo")
                return
            }
            completionHandler(photosArray, nil)
        }
        task.resume()
    }
    
    class func getPhotos(_ galleryID: Int, completionHandler: @escaping ([[String: AnyObject]], Error?) -> Void) {
        var params = baseParams
        params["method"] = "flickr.galleries.getPhotos"
        params["gallery_id"] = galleryID
        
        func handleError(_ message: String) {
            completionHandler([[:]], Error(message: message))
        }
        
        let task = URLSession.shared.dataTask(with: prepareURL(params)) { (data, response, error) in
            guard (error == nil) else {
                handleError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let data = data else {
                handleError("No data was returned by the request!")
                return
            }
            
            var parsedResult: [String: AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            } catch {
                handleError("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let stat = parsedResult["stat"] as? String, stat == "ok" else {
                handleError("Stat fail \(parsedResult)")
                return
            }
            
            guard let photosDict = parsedResult["photos"] as? [String: AnyObject],
                let photosArray = photosDict["photo"] as? [[String: AnyObject]] else
            {
                handleError("Missing key photos or photo")
                return
            }
            completionHandler(photosArray, nil)
        }
        task.resume()
    }
    
    class func escapedParameters(_ parameters: [String: AnyObject]) -> String {
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
