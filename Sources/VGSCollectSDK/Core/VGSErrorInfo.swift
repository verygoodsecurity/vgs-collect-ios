//
//  VGSErrorInfo.swift
//  VGSCollectSDK
//
//  Created by Dima on 27.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

/// Represent default structure of VGSError user info
internal struct VGSErrorInfo {
    let key: VGSErrorInfoKey
    let description: String
    var extraInfo = [String: Any]()
    
    var asDictionary: [String: Any]? {
        return ["key": key,
                NSLocalizedDescriptionKey: description,
                "extraInfo": extraInfo]
    }
}
