//
//  Utils.swift
//  VGSCollectSDK
//
//  Created by Dima on 10.03.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Merge two  <key:value> objects and their nested values. Returns [String: Any]. Values in d2 will override values in d1 if keys are same!!!!
func deepMerge(_ d1: [String: Any], _ d2: [String: Any]) -> [String: Any] {
    var result = d1
    for (k2, v2) in d2 {
        if let v2 = v2 as? [String: Any], let v1 = result[k2] as? [String: Any] {
            result[k2] = deepMerge(v1, v2)
        } else {
            result[k2] = v2
        }
    }
    return result
}

/// Convert string key with separator into dictionary. Ex.: user.name : "Joe" -> ["user": ["name": " Joe"]]
func mapStringKVOToDictionary(key: String, value: Any, separator: String.Element) -> [String: Any] {
    let components = key.split(separator: separator).map { String($0) }
    
    var dict = [String: Any]()
    // swiftlint:disable identifier_name
    var i = components.count - 1
    
    while i >= 0 {
        if i == components.count - 1 {
            dict[components[i]] = value
        } else {
            let newDict = [components[i]: dict]
            dict = newDict
        }
        i -= 1
    }
    // swiftlint:enable identifier_name
    return dict
}

internal class Utils {
  
  /// VGS Collect SDK Version.
	/// Necessary since SPM doesn't track info plist correctly: https://forums.swift.org/t/add-info-plist-on-spm-bundle/40274/5
  static let vgsCollectVersion: String = "1.7.10"
}

extension Dictionary {
    /// Resturn JSON string  representation of dictionary with sorted keys
    @available(iOS 11.0, *)
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted, .sortedKeys]) else {
            return nil
        }

        return String(data: theJSONData, encoding: .ascii)
    }
}
