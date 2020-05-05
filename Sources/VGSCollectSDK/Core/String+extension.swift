//
//  String+extension.swift
//  VGSCollectSDK
//
//  Created by Dima on 10.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal extension String {
    var isAlphaNumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}

internal extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}
