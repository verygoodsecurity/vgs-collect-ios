//
//  VGSCardScanCoordinator.swift
//  VGSCollectSDK
//

import Foundation
import SwiftUI
import Combine

@available(iOS 14.0, *)
/// Coordinates external card scanning integrations with a bound `VGSTextField` (typically a `VGSCardTextField` or its SwiftUI representable).
///
/// Responsibilities:
/// - Holds weak reference to the target text field.
///
/// Usage:
/// 1. Instantiate and pass into a SwiftUI representable via `.cardScanCoordinator(...)`.
/// 2. After a successful scan, automatically populate field & trigger validation.
///
/// Security:
/// - Ensure scanned text is handled only in-memory until submitted or tokenized.
/// - Avoid persisting scanned PAN in logs or user defaults.
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
public extension VGSCardScanCoordinator {
  /// Track a generic scan analytics event. Supply a scanner type identifier (e.g. "blinkcard", "cardIO").
  func trackAnalyticsEvent(scannerType: String) {
    if let form = textField?.configuration?.vgsCollector {
      VGSAnalyticsClient.shared.trackFormEvent(form.formAnalyticsDetails, type: .scan, status: .success, extraData: [ "scannerType": scannerType])
    }
  }
}
