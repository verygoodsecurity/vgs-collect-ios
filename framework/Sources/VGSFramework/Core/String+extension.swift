//
//  String+extension.swift
//  VGSFramework
//
//  Created by Dima on 10.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

extension String {
    var isAlphaNumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
}
