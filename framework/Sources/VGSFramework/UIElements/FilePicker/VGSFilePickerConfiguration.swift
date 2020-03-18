//
//  VGSFilePickerConfiguration.swift
//  VGSFramework
//
//  Created by Dima on 17.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

protocol VGSFilePickerConfigurationProtocol: VGSBaseConfigurationProtocol {

    var fileSource: VGSFileSource { get }
}

/// A class responsible for configuration VGSFilePickerController
public class VGSFilePickerConfiguration: VGSFilePickerConfigurationProtocol {
    
    internal let fileSource: VGSFileSource
    internal weak var vgsCollector: VGSCollect?
    
    /// Name that will be used as a JSON key when submit selected to VGS
    public let fieldName: String
    
    /// Initialization
    ///
    /// - Parameters:
    ///   - vgs: VGSCollect instance
    ///   - fieldName: Name for your selected file
    ///   - fileSource: Type of file source
    public init(collector vgs: VGSCollect, fieldName: String, fileSource: VGSFileSource) {
        self.vgsCollector = vgs
        self.fieldName = fieldName
        self.fileSource = fileSource
    }
}
