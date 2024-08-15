//
//  VGSCardScanCoordinator.swift
//  VGSCollectSDK
//

import Foundation
import SwiftUI

@available(iOS 13.0, *)
public class VGSCardScanCoordinator: ObservableObject {
    private weak var textField: VGSTextField?
  
    public init() {}
    
    // Register the UITextField with the coordinator
    internal func registerTextField(_ textField: VGSTextField) {
        self.textField = textField
    }
    
    // Set text for the text field
    internal func setText(_ text: String) {
        textField?.setText(text)
    }
}
@available(iOS 13.0, *)
internal extension VGSCardScanCoordinator {
  func trackAnalyticsEvent(scannerType: String) {
    if let form = textField?.configuration?.vgsCollector {
      VGSAnalyticsClient.shared.trackFormEvent(form.formAnalyticsDetails, type: .scan, status: .success, extraData: [ "scannerType": scannerType])
    }
  }
}
