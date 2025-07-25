//
//  VGSCardScanCoordinator.swift
//  VGSCollectSDK
//

import Foundation
import SwiftUI
import Combine

@available(iOS 14.0, *)
/// :nodoc:
@MainActor public class VGSCardScanCoordinator: ObservableObject {
    private weak var textField: VGSTextField?
  
    public init() {}
    
    // Register the UITextField with the coordinator
    internal func registerTextField(_ textField: VGSTextField) {
        self.textField = textField
    }
    
    public func setText(_ text: String) {
        textField?.setText(text)
    }
}
@available(iOS 14.0, *)
/// :nodoc:
public extension VGSCardScanCoordinator {
  func trackAnalyticsEvent(scannerType: String) {
    if let form = textField?.configuration?.vgsCollector {
      VGSAnalyticsClient.shared.trackFormEvent(form.formAnalyticsDetails, type: .scan, status: .success, extraData: [ "scannerType": scannerType])
    }
  }
}
