//
//  VGSBlinkCardControllerRepresentable.swift
//  VGSBlinkCardCollector
//

import Foundation
#if os(iOS)
import SwiftUI
import UIKit
#endif

#if canImport(BlinkCard)
import BlinkCard
#if !COCOAPODS
import VGSCollectSDK
#endif

/// UIViewControllerRepresentable responsible for managing `BlinkCard` scanner.
public struct VGSBlinkCardControllerRepresentable: UIViewControllerRepresentable {
  
  public typealias UIViewControllerType = UIViewController
  
  internal lazy var cardRecognizer: MBCBlinkCardRecognizer = {
    return MBCBlinkCardRecognizer()
  }()

  // MARK: - Actions handlers
  /// On Scaner finish card recognition.
  public var onCardScanned: (() -> Void)?
  /// On card scanning canceled  by user.
  public var onCardScanCanceled: (() -> Void)?
    
  // MARK: - MBCBlinkCardRecognizer params
  /// https://blinkcard.github.io/blinkcard-ios/Classes/MBCBlinkCardRecognizer.html
  /// Should extract the card owner information.
  public var extractOwner: Bool = true
  /// Should extract the payment card’s month of expiry.
  public var extractExpiryDate: Bool = true
  /// Should extract CVV.
  public var extractCvv: Bool = true
  /// Should extract the payment card’s IBAN.
  public var extractIban: Bool = true
  /// Whether invalid card number is accepted.
  public var allowInvalidCardNumber: Bool = false
  
  /// Card scan data coordinators dict connects scanned data with VGSTextFields.
  private var dataCoordinators = [VGSBlinkCardDataType: VGSCardScanCoordinator]()
  
  // MARK: - Initialization
  
  /// Initialization
  /// - Parameters:
  ///   - licenseKey: key required for BlinkCard  SDK usage.
  ///   - dataCoordinators: `[VGSBlinkCardDataType: VGSCardScanCoordinator]` represents connection between scanned data and VGSTextFields.
  ///   - errorCallback: Error callback with Int error code(represents `MBCLicenseError` enum), triggered only when error occured.
  public init(licenseKey: String, dataCoordinators: [VGSBlinkCardDataType: VGSCardScanCoordinator], errorCallback: @escaping ((NSInteger) -> Void)) {
      MBCMicroblinkSDK.shared().setLicenseKey(licenseKey) { error in
        VGSAnalyticsClient.shared.trackEvent(.scan, status: .failed, extraData: ["scannerType": "BlinkCard", "errorCode": error])
        errorCallback(error.rawValue)
      }
      self.dataCoordinators = dataCoordinators
  }
    
  public func makeCoordinator() -> Coordinator {
        Coordinator(self)
  }
  
  public func makeUIViewController(context: Context) -> UIViewController {

  // Create BlinkCard settings
  let settings: MBCBlinkCardOverlaySettings = MBCBlinkCardOverlaySettings()
  settings.enableEditScreen = false
  // Set card recognizer
  context.coordinator.parent.cardRecognizer.extractOwner = extractOwner
  context.coordinator.parent.cardRecognizer.extractOwner = extractCvv
  context.coordinator.parent.cardRecognizer.extractOwner = extractExpiryDate
  context.coordinator.parent.cardRecognizer.extractOwner = extractIban
  context.coordinator.parent.cardRecognizer.allowInvalidCardNumber = allowInvalidCardNumber
  // Crate recognizer collection
  let recognizerList = [context.coordinator.parent.cardRecognizer]
  let recognizerCollection: MBCRecognizerCollection = MBCRecognizerCollection(recognizers: recognizerList)
   // Create  overlay view controller
  let blinkCardOverlayViewController = MBCBlinkCardOverlayViewController(settings: settings, recognizerCollection: recognizerCollection, delegate: context.coordinator)
   // Create recognizer view controller with wanted overlay view controller
  let recognizerRunneViewController: UIViewController = MBCViewControllerFactory.recognizerRunnerViewController(withOverlayViewController: blinkCardOverlayViewController)!
//     recognizerRunneViewController.modalPresentationStyle = modalPresentationStyle
      
    return recognizerRunneViewController
  }

  public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
      
  }
  // MARK: - Scan interaction events
  /// On Scaner finish card recognition.
  public func onCardScanned(_ action: (() -> Void)?) -> VGSBlinkCardControllerRepresentable {
    var newRepresentable = self
    newRepresentable.onCardScanned = action
    return newRepresentable
  }
  /// On card scanning canceled  by user.
  public func onCardScanCanceled(_ action: (() -> Void)?) -> VGSBlinkCardControllerRepresentable {
    var newRepresentable = self
    newRepresentable.onCardScanCanceled = action
    return newRepresentable
  }
  // MARK: - MBCBlinkCardRecognizer params setting
  /// https://blinkcard.github.io/blinkcard-ios/Classes/MBCBlinkCardRecognizer.html
  /// Set if should `extractOwner` value.
  public func extractOwner(_ extract: Bool) -> VGSBlinkCardControllerRepresentable {
    var newRepresentable = self
    newRepresentable.extractOwner = extract
    return newRepresentable
  }
  /// Set if should `extractExpiryDate` value.
  public func extractExpiryDate(_ extract: Bool) -> VGSBlinkCardControllerRepresentable {
    var newRepresentable = self
    newRepresentable.extractExpiryDate = extract
    return newRepresentable
  }
  /// Set if should `extractCvv` value.
  public func extractCvv(_ extract: Bool) -> VGSBlinkCardControllerRepresentable {
    var newRepresentable = self
    newRepresentable.extractCvv = extract
    return newRepresentable
  }
  /// Set if should `extractIban` value.
  public func extractIban(_ extract: Bool) -> VGSBlinkCardControllerRepresentable {
    var newRepresentable = self
    newRepresentable.extractIban = extract
    return newRepresentable
  }
  /// Set if should `allowInvalidCardNumber` value.
  public func allowInvalidCardNumber(_ allow: Bool) -> VGSBlinkCardControllerRepresentable {
    var newRepresentable = self
    newRepresentable.allowInvalidCardNumber = allow
    return newRepresentable
  }
  
  // MARK: - Coordinator
  public class Coordinator: NSObject, MBCBlinkCardOverlayViewControllerDelegate {
    var parent: VGSBlinkCardControllerRepresentable
    
    init(_ parent: VGSBlinkCardControllerRepresentable) {
      self.parent = parent
    }
    
    /// When BlinkCard finish card recognition.
    public func blinkCardOverlayViewControllerDidFinishScanning(_ blinkCardOverlayViewController: MBCBlinkCardOverlayViewController, state: MBCRecognizerResultState) {
      // pause scanning
      blinkCardOverlayViewController.recognizerRunnerViewController?.pauseScanning()
      // send results in main thread
      DispatchQueue.main.async { [weak self] in
        guard let strongSelf = self else {return}
        // get scan result and pass to fields coordinator
        let result = strongSelf.parent.cardRecognizer.result
        let dataDict = VGSBlinkCardHandler.mapScanResult(result)
          
        for (dataType, coordinator) in strongSelf.parent.dataCoordinators {
          if let scanData = dataDict[dataType] {
            coordinator.setText(scanData)
          }
          if dataType == .cardNumber {
            coordinator.trackAnalyticsEvent(scannerType: "BlinkCard")
          }
        }
        // notify scan is finished
        strongSelf.parent.onCardScanned?()
        }
      }
    
    /// When user tap close button.
    public func blinkCardOverlayViewControllerDidTapClose(_ blinkCardOverlayViewController: MBCBlinkCardOverlayViewController) {
      VGSAnalyticsClient.shared.trackEvent(.scan, status: .cancel, extraData: [ "scannerType": "BlinkCard"])
      parent.onCardScanCanceled?()
    }
  }
}
#endif
