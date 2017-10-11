//
//  HCService.swift
//
//  Created by Hypercube on 12/12/16.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireNetworkActivityIndicator
import Reachability
import HCFramework

public enum ResponseType
{
    case TypeJSON
    case TypeData
    case TypeString
}

public class HCService: NSObject {
    
    open var token : String = ""
    open var reachability : Reachability! = nil
    
    open static var mySessionMenager: SessionManager! = nil
    open static var internetOn : Bool = true
    
    open static var timeoutIntervalRequest:TimeInterval = 30
    open static var timeoutIntervalResource:TimeInterval = 30
    open static var contentType = "application/json"
    
    open static let shared: HCService = {
    
        let instance = HCService()
        
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        defaultHeaders["Content-Type"] = contentType
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        
        configuration.timeoutIntervalForRequest = timeoutIntervalRequest
        configuration.timeoutIntervalForResource = timeoutIntervalResource
        
        mySessionMenager = Alamofire.SessionManager(configuration: configuration)
    
        NetworkActivityIndicatorManager.shared.isEnabled = true
        
        instance.setupReachability()
        
        return instance
    }()
    
    /// Setup Reachability function
    open func setupReachability()
    {
        reachability = Reachability()!
        
        reachability.whenReachable = { reachability in
            DispatchQueue.main.async() {
                if reachability.isReachableViaWiFi {
                    print("Reachable via WiFi")
                } else {
                    print("Reachable via Cellular")
                }
                HCService.internetOn = true;
                HCAppNotify.postNotification("internetOn")
            }
        }
        reachability.whenUnreachable = { reachability in
            DispatchQueue.main.async() {
                print("Not reachable")
                HCService.internetOn = false;
                HCAppNotify.postNotification("internetOff")
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    /// Function to send request to server
    ///
    /// - Parameters:
    ///   - strURL: First param is URL.
    ///   - path: Path param is appended to URL
    ///   - methodType: HTTP Method. Can be .post, .get, .put...
    ///   - params: Parameters that you send as post values
    ///   - header: Additional heders that are not included in session menager
    ///   - responseType: Select do you want JSON,Data or String response type. Default value is JSON type.
    ///   - success: Success function
    ///   - failure: Failure function
    open func requestWithURL(_ strURL: String, path: String, methodType: Alamofire.HTTPMethod, params: [String : AnyObject]?, header: [String : String]?, responseType:ResponseType = .TypeJSON, success:@escaping(Any) -> Void, failure:@escaping(Any?,Int) -> Void)
    {
        HCService.mySessionMenager.request(strURL+path, method:methodType, parameters:params, headers:header)
            .responseJSON { (responseObject) -> Void in
                if responseType != .TypeJSON
                {
                    return
                }
                if responseObject.response?.statusCode == 401
                {
                    HCAppNotify.postNotification("Unauthorized")
                    return
                }
                
                if responseObject.result.isSuccess && responseObject.response?.statusCode == 200 {
                    success(responseObject.data as Any)
                } else if responseObject.result.isFailure {
                    let error : Error = responseObject.result.error!
                    print(error.localizedDescription)
                    failure(nil,0)
                } else if responseObject.response?.statusCode != 200 {
                    let statusCode = responseObject.response?.statusCode
                    
                    JSONParser.parseError(JSONData: responseObject.data)
                    
                    failure(responseObject.data as Any, statusCode!)
                }
            } .responseString { (responseObject) -> Void in
                if responseType != .TypeString
                {
                    return
                }
                print("****** responseString ******")
                print(responseObject)
                
            } .responseData { (responseObject) -> Void in
                if responseType != .TypeData
                {
                    return
                }
                if responseObject.response?.statusCode == 401
                {
                    HCAppNotify.postNotification("Unauthorized")
                    return
                }
                
                if responseObject.result.isSuccess && responseObject.response?.statusCode == 200 {
                    success(responseObject.data as Any)
                } else if responseObject.result.isFailure {
                    let error : Error = responseObject.result.error!
                    print(error.localizedDescription)
                    failure(nil,0)
                } else if responseObject.response?.statusCode != 200 {
                    let statusCode = responseObject.response?.statusCode
                    
                    JSONParser.parseError(JSONData: responseObject.data)
                    
                    failure(responseObject.data as Any, statusCode!)
                }
                
            } /*.response { (responseObject) -> Void in
                print("response")
        }*/
    }
    
    /// Function to upload multiple images to server.
    ///
    /// - Parameters:
    ///   - strURL: First param is URL.
    ///   - path: Path param is appended to URL
    ///   - images: Array of images fhere key is param name and value is UIImage. Images are sent to server as JPEG
    ///   - params: Parameters that you send as post values
    ///   - header: Additional heders that are not included in session menager
    ///   - success: Success function
    ///   - failure: Failure function
    open func imageUploadWithURL(_ strURL: String, path: String, images:[String :UIImage], params: [String : String]?, header: [String : String]?, success:@escaping(Any) -> Void, failure:@escaping (Any?,Int) -> Void)
    {
        let request = try! URLRequest(url:strURL+path, method: .post, headers:header)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for image in images {
                let fileData = UIImagePNGRepresentation(image.value)!
                multipartFormData.append(fileData, withName: image.key, fileName: "name", mimeType: "image/png")
            }
            
            for (key, value) in params! {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, with: request, encodingCompletion: { (result) in
            
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    if response.result.isFailure
                    {
                        let error : Error = response.result.error!
                        print(error.localizedDescription)
                        failure(nil,0)
                    } else if response.response?.statusCode == 200
                    {
                        success(response.data as Any)
                    } else {
                        let statusCode = response.response?.statusCode
                        failure(response.data,statusCode!)
                    }
                }
            case .failure( _):
                failure(nil,0)
            }
            
        })
    }
}
