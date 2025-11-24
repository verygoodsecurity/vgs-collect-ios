//
//  Storage.swift
//  VGSCollectSDK
//

import Foundation
#if os(iOS)
import UIKit
#endif

/// Class Responsible for storing elements registered with VGSCollect instance.
@MainActor internal class Storage {
    
    /// TextFields attached to `VGSCollect` instance.
    var textFields = [VGSTextField]()
  
    /// File Data attached to`VGSCollect` instance.
    var files = BodyData()
    
    /// TextFields attached to `VGSCollect` instance, with configuration that implements `VGSTextFieldTokenizationConfigurationProtocol`.
    var tokenizableTextFields: [VGSTextField] {
      return textFields.filter {$0.tokenizationParameters != nil}
    }
  
    /// TextFields attached to `VGSCollect` instance, with configuration that DOES NOT  implements `VGSTextFieldTokenizationConfigurationProtocol`.
    var notTokenizibleTextFields: [VGSTextField] {
      return textFields.filter {
        $0.tokenizationParameters == nil &&
        $0.fieldType.sensitive == false
      }
    }
    
    func addTextField(_ textField: VGSTextField) {
        if textFields.filter({ $0 == textField }).count == 0 {
            textFields.append(textField)
        }
    }
    
    func removeTextField(_ textField: VGSTextField) {
        if let index = textFields.firstIndex(of: textField) {
            textFields.remove(at: index)
        }
    }
  
    func removeAllTextFields() {
      textFields = [VGSTextField]()
    }
    
    func removeFiles() {
        files = BodyData()
    }
}
