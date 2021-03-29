//
//  VGSFormatSerializerProtocol.swift
//  VGSCollectSDK
//
//  Created by Dima on 25.03.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

import Foundation

/// Base protocol describing Content Serialization attributes
public protocol VGSFormatSerializerProtocol {

}

/// Base protocol describing functionality for Content Serialization
internal protocol VGSFormatSerializableProtocol {
  func serialize(_ content: String) -> [String: Any]
  var shouldSerialize: Bool { get }
}
