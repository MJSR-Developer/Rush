//
//  APIHelper.swift
//  Rush
//
//  Created by MJ Roldan on 05/07/2017.
//  Copyright © 2017 Mark Joel Roldan. All rights reserved.
//

import Foundation

public struct APIHelper {
    
    public static let shared = APIHelper()

    public func query(_ parameters: Paremeters) -> String {
        var components: StringArray = []

        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(key: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    fileprivate func queryComponents(key: String, value: Any) -> StringArray {
        var components: StringArray = []

        if let dictionary = value as? JSONDictionary {
            for (nestedKey, value) in dictionary {
                components += queryComponents(key: "\(key)[\(nestedKey)]", value: value)
            }
        }
        else if let array = value as? [Any] {
            for (value) in array {
                components += queryComponents(key: "\(key)[]", value: value)
            }
        }
        else if let value = value as? NSNumber {
            if value.boolValue {
                components.append((key, "\(value.boolValue ? "1" : "0")"))
            } else {
                components.append((key, "\(value)"))
            }
        }
        else if let bool = value as? Bool {
            if bool {
                components.append((key, "\(bool ? "1" : "0")"))
            } else {
                components.append((key, "\(value)"))
            }
        }
        else {
            components.append((key, "\(value)"))
        }

        return components
    }

}
