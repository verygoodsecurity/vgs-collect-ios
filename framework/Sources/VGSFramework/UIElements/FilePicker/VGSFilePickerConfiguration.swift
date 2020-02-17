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

public class VGSFilePickerConfiguration: VGSFilePickerConfigurationProtocol {
    
    internal let fileSource: VGSFileSource
    internal weak var vgsCollector: VGSCollect?
    
    /// Field name - actualy this is key for you JSON wich contains data
    public let fieldName: String
    
    public init(collector vgs: VGSCollect, fieldName: String, fileSource: VGSFileSource) {
        self.vgsCollector = vgs
        self.fieldName = fieldName
        self.fileSource = fileSource
    }
}
