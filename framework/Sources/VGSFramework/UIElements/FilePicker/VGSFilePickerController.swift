//
//  VGSFilePickerController.swift
//  VGSFramework
//
//  Created by Dima on 14.02.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

protocol VGSFilePickerConfigurationProtocol: VGSBaseConfigurationProtocol {

    var fileSource: FileSource { get }
}

public class VGSFilePickerConfiguration: VGSFilePickerConfigurationProtocol {
    
    internal let fileSource: FileSource
    private(set) weak var vgsCollector: VGSCollect?
    
    /// Field name - actualy this is key for you JSON wich contains data
    public let fieldName: String
    
    public init(collector vgs: VGSCollect, fieldName: String, fileSource: FileSource) {
        self.vgsCollector = vgs
        self.fieldName = fieldName
        self.fileSource = fileSource
    }
}

internal protocol FilePickerProtocol {
//    var configuration: VGSFilePickerConfiguration { get }
    func present(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?)
}

public class VGSFilePickerController {
    
    internal let configuration: VGSFilePickerConfiguration
    internal lazy var filePicker: FilePickerProtocol = {
        return getFilePicker(configuration.fileSource)
    } ()
    
    public required init(configuration: VGSFilePickerConfiguration) {
        self.configuration = configuration
    }
    
    public func present(on viewController: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        filePicker.present(on: viewController, animated: animated, completion: completion)
    }
    
    ///TODO: delegate metadata
    
    
}

private extension VGSFilePickerController {
    
    func getFilePicker(_ fileSource: FileSource) -> FilePickerProtocol {
        switch fileSource {
        case .camera:
            return VGSImagePicker(configuration: configuration, sourceType: .camera)
        case .library:
            return VGSImagePicker(configuration: configuration, sourceType: .photoLibrary)
        case .file:
            return VGSDocumentPicker(configuration: configuration)
        }
    }
}
