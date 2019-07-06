//
//  NetworkCommuncation.swift
//  System7
//
//  Created by Mark Volpe on 2019-03-11.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import Foundation

class NetworkCommunication: NSObject, URLSessionDelegate {
    public static let sharedInstance = NetworkCommunication()
    
    fileprivate var networkCommunicationQueue:OperationQueue? = nil
    fileprivate var networkSession : URLSession? = nil
    fileprivate var defaultHeaders:[String:String] = [:]
    
    struct NetworkRequestOptions: OptionSet {
        let rawValue: Int
        
        static let useDefaultHeaders   = NetworkRequestOptions(rawValue: 1 << 0)
        static let useCustomHeaders     = NetworkRequestOptions(rawValue: 1 << 1)
        
        static let defaultSetting: NetworkRequestOptions = [.useDefaultHeaders]
        static let combinedHeaders: NetworkRequestOptions = [.useDefaultHeaders, .useCustomHeaders]
    }
    
    enum NetworkError : Int{
        case NoSession = 1001
    }
    
    override fileprivate init(){
        super.init()
        networkCommunicationQueue = OperationQueue()
        networkCommunicationQueue?.maxConcurrentOperationCount = 20
        networkSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: networkCommunicationQueue)
    }
    
    private func getSessionRequest(url:URL, customHeaders:[String:String], options:NetworkRequestOptions)->URLRequest{
        var urlRequest = URLRequest(url: url)
        // set standard headers if we have that option
        if options.contains(NetworkRequestOptions.useDefaultHeaders){
            for (key, value) in defaultHeaders{
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        if options.contains(NetworkRequestOptions.useCustomHeaders){
            for (key, value) in customHeaders{
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        return urlRequest
    }
    
    public func setDefaultHeaders(defaultHeaders:[String:String]){
        self.defaultHeaders = defaultHeaders
    }
    
    public func getRequest(urlString:String, customHeaders:[String:String] = [:], options:NetworkRequestOptions = NetworkRequestOptions.defaultSetting, completion:@escaping ((Data?, Error?)->Void)){
        guard networkSession != nil else{
            let error = ChallengeTVError.createError(type: ChallengeErrorType.CET_NO_NETWORK_SESSION)
            completion(nil, error)
            return
        }
        if let url = URL(string: urlString){
            let urlRequest = getSessionRequest(url: url, customHeaders: customHeaders, options: options)
            
            let task = networkSession?.dataTask(with: urlRequest, completionHandler: { (data, urlResponse, error) in
                if data != nil {
                    completion(data, error)
                }else{
                    completion(nil, error)
                }
            })
            
            task?.resume()
        }else{
            let error = ChallengeTVError.createError(type: ChallengeErrorType.CET_FAILED_TO_PARSE_URL)
            completion(nil, error)
        }
    }
    
    public func postRequest(urlString:String, postBody:[String:Any], customHeaders:[String:String] = [:], options:NetworkRequestOptions = NetworkRequestOptions.defaultSetting, completion:@escaping ((Data?, Error?)->Void)){
        guard networkSession != nil else{
            let error = ChallengeTVError.createError(type: ChallengeErrorType.CET_NO_NETWORK_SESSION)
            completion(nil, error)
            return
        }
        if let url = URL(string: urlString){
            var urlRequest = getSessionRequest(url: url, customHeaders: customHeaders, options: options)
            urlRequest.httpMethod = "POST"
            guard let httpBody = try? JSONSerialization.data(withJSONObject: postBody, options: []) else{
                completion(nil, nil)
                return
            }
            urlRequest.httpBody = httpBody
            
            let task = networkSession?.dataTask(with: urlRequest, completionHandler: { (data, urlResponse, error) in
                if data != nil {
                    completion(data, error)
                }else{
                    completion(nil, error)
                }
            })
            
            task?.resume()
        }else{
            let error = ChallengeTVError.createError(type: ChallengeErrorType.CET_FAILED_TO_PARSE_URL)
            completion(nil, error)
        }
    }
}
