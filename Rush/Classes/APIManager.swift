//
//  API.swift
//  Rush
//
//  Created by MJ Roldan on 05/07/2017.
//  Copyright © 2017 Mark Joel Roldan. All rights reserved.
//

import Foundation

// MARK: HTTPMethod
enum HTTPMethod: String {
    case post   = "POST"
    case get    = "GET"
}

class APIManager: NSObject {

    let session: URLSession?
    fileprivate var reachability: Reachability?

    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.allowsCellularAccess = true
        configuration.timeoutIntervalForRequest = 45.0

        self.session = URLSession(configuration: configuration)
        self.reachability = Reachability()
        super.init()
    }

    func request(_ request: Request,
                 success: @escaping (JSONDictionary) -> Void,
                 failed: @escaping (APIErrorCode) -> Void) {

        if self.canConnect() {
            guard let _ = request.url else {
                failed(.invalidURL)
                return
            }

            let urlRequest = self.urlRequest(request)
            self.dataRequest(urlRequest, success: { (result) in
                success(result)
            }) { (error) in
                failed(error)
            }
        } else {
            failed(.noInternet)
        }

    }

    fileprivate func urlRequest(_ request: Request) -> URLRequest {
        var _urlRequest = URLRequest(url: request.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 45.0)
        _urlRequest.httpMethod = request.method.rawValue
        _urlRequest.allHTTPHeaderFields = request.headers

        if let parameters = request.parameters {
            _urlRequest.httpBody = APIHelper.shared.query(parameters).data(using: .utf8, allowLossyConversion: false)
        }
        
        return _urlRequest
    }

    fileprivate func dataRequest(_ urlRequest: URLRequest,
                                 success: @escaping (JSONDictionary) -> Void,
                                 failed: @escaping (APIErrorCode) -> Void) {

        self.session?.dataTask(with: urlRequest, completionHandler: { (data, response, error) in

            guard let data = data, error == nil else {
                // failed
                if let _error = error as? NSError {
                    let apiError = APIError.urlErrorDomain(_error)
                    failed(apiError)
                }
                return
            }

            do {
                guard let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSONDictionary else {
                    // failed
                    if let httpResponse = response as? HTTPURLResponse, let errorCode = APIError.responseStatus(httpResponse) {
                        failed(errorCode)
                    } else {
                        failed(.invalidData)
                    }
                    return
                }
                // success
                success(jsonResult)
            } catch {
                // failed
                failed(.invalidData)
            }

        }).resume()
    }

}

extension APIManager {
    func canConnect() -> Bool {
        if let reachable = self.reachability, reachable.isReachableViaWiFi || reachable.isReachableViaWWAN {
            return true
        } else if let reachable = self.reachability {
            if !reachable.isReachable {
                return false
            }
        }
        return false
    }
}
