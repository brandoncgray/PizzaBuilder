//
//  RestfulServices.swift
//  URLSession
//
//  Created by Brandon Gray on 10/4/16.
//  Copyright © 2016 Brandon Gray. All rights reserved.
//

import UIKit

let baseAPIURL = "http://192.168.99.100:3000/"

class RestfulService {
    
    class func get(api:String, response successful: ((_ json:String) -> Swift.Void)? = nil,failure: (() -> Swift.Void)? = nil)  {
        RestfulService().request(url: api, isPost: false, successful: successful, failure: failure)
    }
    
    class func post(api:String, body:String, response successful: ((_ json:String) -> Swift.Void)? = nil,failure: (() -> Swift.Void)? = nil) {
        RestfulService().request(url: api, isPost: true, body:body, successful: successful, failure: failure)
    }
    
    func request(url:String, isPost:Bool, body:String? = nil, successful: ((_ json:String) -> Swift.Void)? = nil,failure: (() -> Swift.Void)? = nil) {
        let body = body?.replacingOccurrences(of: "desc", with: "description") //description is a protected name by Swift; the JSONSwift Framwork maps data by property name

        var requestType = "GET"
        if isPost {
            requestType = "POST"
        }
        
        // Create default URLSessionConfiguration
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 2.0

        // Create URLSession with configuration
        let session = URLSession(configuration: config)
        let request = NSMutableURLRequest(url: URL(string: "\(baseAPIURL)\(url)")!)

        // Add headers and requestType
        if isPost {
            request.addValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = body?.data(using: .utf8)
        }else{
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        request.httpMethod = requestType
        
        // Create URLSession task
        var task = URLSessionDataTask()
        
        task = session.dataTask(with: request as URLRequest) {
            data, response, error in
            guard data != nil,response != nil else {
                failure?()
                return
            }

//            print(response ?? "Nil Response")
            if (response as? HTTPURLResponse) != nil {
                if var dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as String? {
                    dataString = dataString.replacingOccurrences(of: "description", with: "desc") //description is a protected name by Swift; the JSONSwift Framwork maps data by property name
                    let httpResponse = response as! HTTPURLResponse
                    
//                    print(httpResponse.statusCode)
                    if httpResponse.statusCode == 200 {
                        successful?(dataString)
                    }else{
                        failure?()
                    }
                }else{
                    failure?()
                }
            }
            
        }
        task.resume()
    }
}
