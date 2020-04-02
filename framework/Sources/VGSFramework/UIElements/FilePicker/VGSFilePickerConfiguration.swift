//
//  VGSFilePickerConfiguration.swift
//  VGSFramework
//
//  Created by Dima on 17.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal protocol VGSFilePickerConfigurationProtocol: VGSBaseConfigurationProtocol {

    var fileSource: VGSFileSource { get }
}

/// A class responsible for configuration `VGSFilePickerController`
public class VGSFilePickerConfiguration: VGSFilePickerConfigurationProtocol {
    
    internal let fileSource: VGSFileSource
    internal weak var vgsCollector: VGSCollect?
    
    /// Name that will be associated with selected file by user. Used as a JSON key on submitting file data to your organozation vault
    public let fieldName: String
    
    /// Initialization
    ///
    /// - Parameters:
    ///   - vgs: `VGSCollect` instance
    ///   - fieldName: name that should be associated with selected file
    ///   - fileSource: type of `VGSFileSource` that should be provided to user
    public init(collector vgs: VGSCollect, fieldName: String, fileSource: VGSFileSource) {
        self.vgsCollector = vgs
        self.fieldName = fieldName
        self.fileSource = fileSource
    }
}
