//
//  ImageManager.swift
//  ImageViewer
//
//  Created by Aman gupta on 03/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//


import Foundation
import UIKit

let flickrKey = "205c35ec47a1e2a0478cf8b2e5c05463"
let flickrSecret = "6637219e5a9d09a9"
let flickrBaseURL = "https://api.flickr.com/services/rest/"
let flickrPerPageImages = "30"
let imageCache = "ImageCache"
let mb = 1024 * 1024

typealias ImageFetchCompletion = (_ images: Array<Photo>?, _ totalPage: Int, _ currentPage: Int, _ searchText: String) -> ()
typealias ImageDownloadCompletion = (_ imageURL: String, _ image: UIImage?) -> ()


// MARK: - Image Manager Methods
class ImageManager: NSObject, URLSessionTaskDelegate {
    static let shared = ImageManager()
    let operationQueue: OperationQueue = OperationQueue()
    var urlCache = URLCache(memoryCapacity: 20 * mb, diskCapacity: 100 * mb, diskPath: imageCache)
    var requestQueue: Dictionary<URL, URLSessionDataTask> = [:]
    var session: URLSession!
    
    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = urlCache
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: operationQueue)
        
    }
    
}

extension ImageManager {
    func downloadImage(imageURL: String, completion: ImageDownloadCompletion?) {
        if let url = URL(string: imageURL) {
            let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
            // Check for image in cache
            if let response = urlCache.cachedResponse(for: urlRequest) {
                let image = UIImage(data: response.data)
                completion?(imageURL, image)
            } else {
                
                // Check if image request is already present
                if let task = requestQueue[url] {
                    task.priority = URLSessionTask.highPriority
                } else {
                    // Else download
                    self.download(imageURL: imageURL, completion: completion)
                }
            }
            
        } else {
            completion?(imageURL, nil)
        }
        
    }
    
    private func download(imageURL: String, completion: ImageDownloadCompletion?) {
        if let url = URL(string: imageURL) {
            // Create request
            let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
            
            let task = self.session.dataTask(with: urlRequest) {[weak self] (data, response, error) in
                
                if let data = data, let image = UIImage(data: data) {
                    completion?(imageURL, image)
                } else {
                    completion?(imageURL, nil)
                }
                self?.removeRequestFromQueue(url: url)
            }
            
            task.priority = URLSessionTask.highPriority
            requestQueue[url] = task
            task.resume()
            
        } else {
            completion?(imageURL, nil)
        }
        
    }
    
    private func removeRequestFromQueue(url: URL) {
        requestQueue.removeValue(forKey: url)
    }
    
    func setLowPriority(url: URL) {
        if let task = requestQueue[url] {
            task.priority = URLSessionTask.lowPriority
        }
    }
    
}

// MARK: - Images List Fetch
extension ImageManager {
    func fetchImages(text: String, currentPage: Int, completion: ImageFetchCompletion?) {
        let parameters = [NetworkAPIKeys.method: NetworkAPIKeys.flickrPhotoSearch, NetworkAPIKeys.apiKey:flickrKey, NetworkAPIKeys.text: text, NetworkAPIKeys.perPage : flickrPerPageImages, NetworkAPIKeys.format: NetworkAPIKeys.json, NetworkAPIKeys.nojsoncallback : "1", NetworkAPIKeys.page: String(currentPage)]
        
        let stringParameters = NetworkHandler.sharedInstance.stringFromQueryParameters(parameters)
        let urlString = "\(flickrBaseURL)?\(stringParameters)"
        
        
        NetworkHandler.sharedInstance.requestApi(serviceUrl: urlString, method: .get, postData: [:], withProgressHUD: false) { (data, error, errorType, statusCode) in
            if errorType == .requestSuccess {
                switch statusCode {
                case 200, 201:
                    if let result = data as? JSONDictionary,
                        let photosDict = result[NetworkAPIKeys.photos] as? JSONDictionary,
                        let photoArray = photosDict[NetworkAPIKeys.photo] as? Array<JSONDictionary>,
                        let totalPage = photosDict[NetworkAPIKeys.pages] as? Int,
                        let currentPage = photosDict[NetworkAPIKeys.page] as? Int{
                        
                        var photos: Array<Photo> = []
                        for photoDict in photoArray {
                            if let photo = Photo(with: photoDict) {
                                photos.append(photo)
                            }
                        }
                        completion?(photos,totalPage, currentPage, text)
                    } else {
                        completion?(nil, 0, 0, text)
                    }
                    
                default:
                    completion?(nil, 0, 0, text)
                    break
                }
            }
        }
    }
    
}

