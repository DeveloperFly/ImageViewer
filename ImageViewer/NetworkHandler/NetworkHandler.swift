//
//  NetworkHandler.swift
//  ImageViewer
//
//  Created by Aman gupta on 03/09/19.
//  Copyright © 2019 Aman Gupta. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

//MARK:- base urls and keys
let kBaseUrl = ""


typealias CompletionHandler = (_ status:Bool, _ responseObj:Any?,_ error: Error?, _ statusCode:Int?) -> Void
typealias ProgressHandler = (_ fractionCompleted:Double)-> Void
typealias JSONDictionary = [String:AnyObject]

class NetworkHandler: NSObject {
    
    // MARK: - Properties
    /**
     A shared instance of `Manager`, used by top-level Alamofire request methods, and suitable for use directly
     for any ad hoc requests.
     */
    internal static let sharedInstance: NetworkHandler = {
        return NetworkHandler()
    }()
    
    // MARK: - Public Method
    /**
     *  Initiates HTTPS or HTTP request over |kHTTPMethod| method and returns call back in success and failure block.
     *
     *  @param serviceName  name of the service
     *  @param method       method type like Get and Post
     *  @param postData     parameters
     *  @param responeBlock call back in block
     */
    // swiftlint:disable:next cyclomatic_complexity
    func requestApi(serviceUrl: String,
                    method: HTTPMethod,
                    postData: [String: Any],
                    withProgressHUD showProgress: Bool,
                    hudText: String = Constant.hudDefaultText,
                    completionClosure: @escaping (_ result: Any?, _ error: Error?, _ errorType: RequestStatus, _ statusCode: Int?) -> Void) {
        
        if NetworkReachabilityManager()?.isReachable == true {
            if showProgress {
                addMBProgressHUD(hudText: hudText)
            }
            var headers: [String: String] = [:]
            headers = getHeaders()
            
            CommonUtils.debug_logs(arg: "Connecting to Host with URL \(serviceUrl) with parameters: \(postData) headers: \(self.getHeaders())")
            switch method {
            case .get:
                Alamofire.request(serviceUrl,
                                  method: .get,
                                  parameters: postData,
                                  encoding: URLEncoding.default,
                                  headers: headers).responseJSON(completionHandler: {(apiDataResponse) in
                                    self.hideMBProgressHUD()
                                    switch apiDataResponse.result {
                                    case .success(let JSON):
                                        CommonUtils.debug_logs(arg: "Success with status Code: \(String(describing: apiDataResponse.response?.statusCode))  Response : \(JSON)")
                                        let response = self.getResponseDataDictionaryFromData(data: apiDataResponse.data!)
                                        completionClosure(response.responseData, nil, .requestSuccess, apiDataResponse.response?.statusCode)
                                    case .failure(let error):
                                        CommonUtils.debug_logs(arg: "json error: \(error.localizedDescription)")
                                        if error.localizedDescription == "cancelled" {
                                            completionClosure(nil, error, RequestStatus.requestCancelled, apiDataResponse.response?.statusCode)
                                        } else {
                                            completionClosure(nil, error, .requestFailed, apiDataResponse.response?.statusCode)
                                        }
                                    }
                                  })
            case .post:
                Alamofire.request(serviceUrl,
                                  method: .post,
                                  parameters: postData,
                                  encoding: URLEncoding.default,
                                  headers: headers).responseJSON(completionHandler: {(apiDataResponse) in
                                    self.hideMBProgressHUD()
                                    switch apiDataResponse.result {
                                    case .success(let JSON):
                                        CommonUtils.debug_logs(arg: "Success with status Code: \(String(describing: apiDataResponse.response?.statusCode))  Response : \(JSON)")
                                        let response = self.getResponseDataDictionaryFromData(data: apiDataResponse.data!)
                                        completionClosure(response.responseData, nil, .requestSuccess, apiDataResponse.response?.statusCode)
                                    case .failure(let error):
                                        CommonUtils.debug_logs(arg: "json error: \(error.localizedDescription)")
                                        completionClosure(nil, error, .requestFailed, apiDataResponse.response?.statusCode)
                                    }
                                  })
            case .put:
                Alamofire.request(serviceUrl,
                                  method: .put,
                                  parameters: postData,
                                  encoding: URLEncoding.default,
                                  headers: headers).responseJSON(completionHandler: {(apiDataResponse) in
                                    self.hideMBProgressHUD()
                                    switch apiDataResponse.result {
                                    case .success(let JSON):
                                        CommonUtils.debug_logs(arg: "Success with status Code: \(String(describing: apiDataResponse.response?.statusCode))  Response : \(JSON)")
                                        let response = self.getResponseDataDictionaryFromData(data: apiDataResponse.data!)
                                        completionClosure(response.responseData, nil, .requestSuccess, apiDataResponse.response?.statusCode)
                                    case .failure(let error):
                                        CommonUtils.debug_logs(arg: "json error: \(error.localizedDescription)")
                                        completionClosure(nil, error, .requestFailed, apiDataResponse.response?.statusCode)
                                    }
                                  })
            case .patch:
                Alamofire.request(serviceUrl,
                                  method: .patch,
                                  parameters: postData,
                                  encoding: URLEncoding.default,
                                  headers: headers).responseJSON(completionHandler: {(apiDataResponse) in
                                    self.hideMBProgressHUD()
                                    switch apiDataResponse.result {
                                    case .success(let JSON):
                                        CommonUtils.debug_logs(arg: "Success with status Code: \(String(describing: apiDataResponse.response?.statusCode))  Response : \(JSON)")
                                        let response = self.getResponseDataDictionaryFromData(data: apiDataResponse.data!)
                                        completionClosure(response.responseData, nil, .requestSuccess, apiDataResponse.response?.statusCode)
                                    case .failure(let error):
                                        CommonUtils.debug_logs(arg: "json error: \(error.localizedDescription)")
                                        completionClosure(nil, error, .requestFailed, apiDataResponse.response?.statusCode)
                                    }
                                  })
            case .delete:
                Alamofire.request(serviceUrl,
                                  method: .delete,
                                  parameters: postData,
                                  encoding: URLEncoding.default,
                                  headers: headers).responseJSON(completionHandler: {(apiDataResponse) in
                                    self.hideMBProgressHUD()
                                    switch apiDataResponse.result {
                                    case .success(let JSON):
                                        CommonUtils.debug_logs(arg: "Success with status Code: \(String(describing: apiDataResponse.response?.statusCode))  Response : \(JSON)")
                                        completionClosure(apiDataResponse.data, nil, .requestSuccess, apiDataResponse.response?.statusCode)
                                    case .failure(let error):
                                        CommonUtils.debug_logs(arg: "json error: \(error.localizedDescription)")
                                        completionClosure(nil, error, .requestFailed, apiDataResponse.response?.statusCode)
                                    }
                                  })
            }
        } else {
            self.hideMBProgressHUD()
            completionClosure(nil, nil, .noNetwork, nil)
        }
    }
    
    //Check if some other user has logged in using the same id and if so then logout the user id from current device
//    func checkForSessionExpire(statusCode: Int) -> Bool {
//        if statusCode == 401 && CommonUtils.getCurrentAccessToken() != nil {
//            return true
//        } else {
//            return false
//        }
//    }
    
    //Used to cancel all running api call requests
    func cancelAllRequests(completionHandler: @escaping () -> Void) {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { (dataTask: [URLSessionDataTask], uploadTask: [URLSessionUploadTask], downloadTask: [URLSessionDownloadTask]) in
            dataTask.forEach({ (task: URLSessionDataTask) in task.cancel() })
            uploadTask.forEach({ (task: URLSessionUploadTask) in task.cancel() })
            downloadTask.forEach({ (task: URLSessionDownloadTask) in task.cancel() })
            completionHandler()
        }
    }
    
    // MARK: - Add/Remove progress bar
    
    func addMBProgressHUD(hudText: String = Constant.hudDefaultText) {
        if let window = kAppDelegate.window {
            DispatchQueue.main.async {
                let hud = MBProgressHUD.showAdded(to: window, animated: true)
                //                hud.label.text = hudText
                hud.mode = .indeterminate
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
    }
    
    func hideMBProgressHUD() {
        if let window = kAppDelegate.window {
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: window, animated: true)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    //Get header for api's call request
    private func getHeaders() -> [String: String] {
        var headers: [String: String] = ["Content-Type": "application/x-www-form-urlencoded"]
//        if let token = CommonUtils.getCurrentAccessToken()?.accessToken {
//            headers["Authorization"] = "\(kTokenType) \(token)"
//        }
        return headers
    }
    
    //Function to get current time stamp at any moment
    private func getCurrentTimeStamp() -> TimeInterval {
        return NSDate().timeIntervalSince1970.rounded()
    }
    
    private func getResponseDataDictionaryFromData(data: Data) -> (responseData: Dictionary<String, Any>?, error: Error?) {
        do {
            let responseData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? Dictionary<String, Any>
            CommonUtils.debug_logs(arg: "Success with JSON: \(responseData)")
            return (responseData, nil)
        } catch let error {
            CommonUtils.debug_logs(arg: "json error: \(error.localizedDescription)")
            return (nil, error)
        }
    }
}

extension NetworkHandler {
    static func isConnected(showAlert: Bool) -> Bool {
        var val = false
        if let reachability = Reachability() {
            switch reachability.connection {
            case .none:
                val = false
            default:
                val = true
            }
        }
        if !val && showAlert {
            //  UIAlertController.showAlertOf(alertStyle: .alert, message: "No Internet Connection", completion: nil)
        }
        return val
    }
}

//MARK:- Parameters to String
extension NetworkHandler {
    func stringFromQueryParameters(_ queryParameters : Dictionary<String, String>) -> String {
        var parts: [String] = []
        
        for (name, value) in queryParameters {
            let escapedName = name.urlEncoded()
            let escapedValue = value.urlEncoded()
            let part = "\(escapedName)=\(escapedValue)"
            
            parts.append(part as String)
        }
        
        return parts.joined(separator: "&")
    }
    
    
}
