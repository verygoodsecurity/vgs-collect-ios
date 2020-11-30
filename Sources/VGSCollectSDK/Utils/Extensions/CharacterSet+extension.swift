//
//  CharacterSet+extension.swift
//  VGSCollectSDK
//
//  Created by Dima on 17.12.2019.
//

import Foundation

extension CharacterSet {
    public static var vgsAsciiDecimalDigits: CharacterSet {
        return self.init(charactersIn: "0123456789")
    }
}
