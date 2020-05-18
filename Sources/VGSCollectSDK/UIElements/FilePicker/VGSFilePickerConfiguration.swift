//
//  VGSFilePickerConfiguration.swift
//  VGSCollectSDK
//
//  Created by Dima on 17.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal protocol VGSFilePickerConfigurationProtocol: VGSBaseConfigurationProtocol {

    var fileSource: VGSFileSource { get }
}

/// A class responsible for configuration `VGSFilePickerController`.
public class VGSFilePickerConfiguration: VGSFilePickerConfigurationProtocol {
    
    // MARK: - Attributes
    
    internal let fileSource: VGSFileSource
    internal weak var vgsCollector: VGSCollect?
    
    /// Name that will be associated with selected file by user. Used as a JSON key on send request with file data to your organozation vault.
    public let fieldName: String
    
    // MARK: - Initialization
    
    /// Initialization
    ///
    /// - Parameters:
    ///   - vgs: `VGSCollect` instance.
    ///   - fieldName: name that should be associated with selected file.
    ///   - fileSource: type of `VGSFileSource` that should be provided to user.
    public init(collector vgs: VGSCollect, fieldName: String, fileSource: VGSFileSource) {
        self.vgsCollector = vgs
        self.fieldName = fieldName
        self.fileSource = fileSource
    }
}
