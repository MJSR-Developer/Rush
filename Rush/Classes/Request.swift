//
//  Request.swift
//  Rush
//
//  Created by MJ Roldan on 06/07/2017.
//  Copyright © 2017 Mark Joel Roldan. All rights reserved.
//

import Foundation

public class Request {
    var url: URL? = nil
    var method: HTTPMethod = .get
    var parameters: Paremeters? = nil
    var headers: HTTPHeaders? = nil

    public init(url: URL?, method: HTTPMethod, parameters: Paremeters?, headers: HTTPHeaders?) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.headers = headers
    }
}
