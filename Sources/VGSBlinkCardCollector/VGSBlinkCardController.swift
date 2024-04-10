//
//  VGSBlinkCardController.swift
//  VGSBlinkCardCollector
//

import Foundation
#if !COCOAPODS
import VGSCollectSDK
#endif
#if os(iOS)
import UIKit
#endif

/// Controller responsible for managing `BlinkCard` scanner.
@available(iOS 13.0, *)
public class VGSBlinkCardController {
    
    // MARK: - Attributes
  
    /// Handle card scanner events.
    internal var scanHandler: VGSBlinkCardHandler?
    
    /// `VGSBlinkCardControllerDelegate` - handle user interaction with `BlinkCard` scanner.
    public var delegate: VGSBlinkCardControllerDelegate? {
      get {
        return scanHandler?.delegate
      }
      set {
        scanHandler?.delegate = newValue
      }
    }
    
    // MARK: - MBCBlinkCardRecognizer params
    /// https://blinkcard.github.io/blinkcard-ios/Classes/MBCBlinkCardRecognizer.html

    /// Should extract the card owner information.
    public var extractOwner: Bool {
      didSet {scanHandler?.cardRecognizer.extractOwner = extractOwner }
    }
    /// Should extract the payment card’s month of expiry.
    public var extractExpiryDate: Bool {
      didSet {scanHandler?.cardRecognizer.extractExpiryDate = extractExpiryDate }
    }
    /// Should extract CVV.
    public var extractCvv: Bool {
      didSet {scanHandler?.cardRecognizer.extractCvv = extractCvv }
    }
    /// Should extract the payment card’s IBAN.
    public var extractIban: Bool {
      didSet {scanHandler?.cardRecognizer.extractIban = extractIban }
    }
    /// Whether invalid card number is accepted.
    public var allowInvalidCardNumber: Bool {
      didSet {scanHandler?.cardRecognizer.allowInvalidCardNumber = allowInvalidCardNumber }
    }
    
    // MARK: - Initialization
    
    /// Initialization
    /// - Parameters:
    ///   - licenseKey: key required for BlinkCard  SDK usage.
    ///   - delegate: `VGSBlinkCardControllerDelegate`. Default is `nil`.
    ///   - errorCallback: Error callback with Int error code(represents `MBCLicenseError` enum), triggered only when error occured.
  public required init(licenseKey: String, delegate: VGSBlinkCardControllerDelegate? = nil, onError errorCallback: @escaping ((NSInteger) -> Void)) {
      self.scanHandler = VGSBlinkCardHandler(licenseKey: licenseKey, errorCallback: errorCallback)
      self.delegate = delegate
    }
    
    // MARK: - Methods
    
    /// Present `BlinkCard` scanner.
    /// - Parameters:
    ///   - viewController: `UIViewController` that will present card scanner.
    ///   - animated: pass `true` to animate the presentation; otherwise, pass `false`.
    ///   - modalPresentationStyle: `UIModalPresentationStyle` object, modal presentation style. Default is `.overCurrentContext`.
    ///   - completion: the block to execute after the presentation finishes.
    public func presentCardScanner(on viewController: UIViewController, animated: Bool, modalPresentationStyle: UIModalPresentationStyle = .overCurrentContext, completion: (() -> Void)?) {
      scanHandler?.presentScanVC(on: viewController, animated: animated, modalPresentationStyle: modalPresentationStyle, completion: completion)
    }
    
    /// Dismiss `BlinkCard` scanner.
    /// - Parameters:
    ///   - animated: pass `true` to animate the dismiss of presented viewcontroller; otherwise, pass `false`.
    ///   - completion: the block to execute after the dismiss finishes.
    public func dismissCardScanner(animated: Bool, completion: (() -> Void)?) {
        scanHandler?.dismissScanVC(animated: animated, completion: completion)
    }
  
    /// Set custom localization fileName.
    public static func setCustomLocalization(fileName: String) {
      VGSBlinkCardHandler.setCustomLocalization(fileName: fileName)
    }
}
