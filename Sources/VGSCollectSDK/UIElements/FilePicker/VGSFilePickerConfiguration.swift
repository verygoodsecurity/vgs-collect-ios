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
    
    /// JSON key for the selected file when the collector submits file data to your tenant.
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
