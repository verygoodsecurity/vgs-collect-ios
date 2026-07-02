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
@available(iOS 16.0, *)
@MainActor
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
    
    /// Should extract the card owner information.
    public var extractOwner: Bool = true {
      didSet {scanHandler?.configuration.extractOwner = extractOwner }
    }
    /// Should extract the payment card’s month of expiry.
    public var extractExpiryDate: Bool = true {
      didSet {scanHandler?.configuration.extractExpiryDate = extractExpiryDate }
    }
    /// Should extract CVV.
    public var extractCvv: Bool = true {
      didSet {scanHandler?.configuration.extractCvv = extractCvv }
    }
    /// Should extract the payment card’s IBAN.
    public var extractIban: Bool = true {
      didSet {scanHandler?.configuration.extractIban = extractIban }
    }
    /// Whether invalid card number is accepted.
    public var allowInvalidCardNumber: Bool = false {
      didSet {scanHandler?.configuration.allowInvalidCardNumber = allowInvalidCardNumber }
    }
  
    // MARK: - Overlay settings
    /// Defines whether button for presenting onboarding screens will be present on screen. Default: true.
    public var showOnboardingInfo: Bool = true {
      didSet {scanHandler?.configuration.showOnboardingInfo = showOnboardingInfo }
    }
    /// Defines whether tutorial alert will be presented on appear. Default: true.
    public var showIntroductionDialog: Bool = true {
      didSet {scanHandler?.configuration.showIntroductionDialog = showIntroductionDialog }
    }
  
    // MARK: - Initialization
    
    /// Initialization
    /// - Parameters:
    ///   - licenseKey: key required for BlinkCard  SDK usage.
    ///   - delegate: `VGSBlinkCardControllerDelegate`. Default is `nil`.
    ///   - errorCallback: Error callback with safe scanner initialization error code, triggered only when an error occurs.
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
  
    /// BlinkCard v3000 uses package localization resources. This method is retained for source compatibility.
    @available(*, deprecated, message: "BlinkCard v3000 uses BlinkCardUX package localization resources.")
    public static func setCustomLocalization(fileName: String) {
      VGSBlinkCardHandler.setCustomLocalization(fileName: fileName)
    }
}
