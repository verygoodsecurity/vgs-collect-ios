//
//  VGSBlinkCardControllerRepresentable.swift
//  VGSBlinkCardCollector
//

import Foundation
#if os(iOS)
import SwiftUI
import UIKit
#endif

#if canImport(BlinkCard) && canImport(BlinkCardUX)
import BlinkCard
import BlinkCardUX
#if !COCOAPODS
import VGSCollectSDK
#endif

/// UIViewControllerRepresentable responsible for managing `BlinkCard` scanner.
@available(iOS 16.0, *)
public struct VGSBlinkCardControllerRepresentable: UIViewControllerRepresentable {
  public typealias UIViewControllerType = UIViewController

  // MARK: - Actions handlers
  /// On scanner finish card recognition.
  public var onCardScanned: (() -> Void)?
  /// On card scanning canceled by user.
  public var onCardScanCanceled: (() -> Void)?

  // MARK: - BlinkCard extraction and UX settings
  /// Should extract the card owner information.
  public var extractOwner: Bool = true
  /// Should extract the payment card's month of expiry.
  public var extractExpiryDate: Bool = true
  /// Should extract CVV.
  public var extractCvv: Bool = true
  /// Should extract the payment card's IBAN.
  public var extractIban: Bool = true
  /// Whether invalid card number is accepted.
  public var allowInvalidCardNumber: Bool = false
  /// Defines whether button for presenting onboarding screens will be present on screen.
  public var showOnboardingInfo: Bool = true
  /// Defines whether tutorial alert will be presented on appear.
  public var showIntroductionDialog: Bool = true

  /// Card scan data coordinators dict connects scanned data with VGSTextFields.
  private var dataCoordinators = [VGSBlinkCardDataType: VGSCardScanCoordinator]()
  private let licenseKey: String
  private let errorCallback: (NSInteger) -> Void

  // MARK: - Initialization

  /// Initialization
  /// - Parameters:
  ///   - licenseKey: key required for BlinkCard SDK usage.
  ///   - dataCoordinators: `[VGSBlinkCardDataType: VGSCardScanCoordinator]` represents connection between scanned data and VGSTextFields.
  ///   - errorCallback: Error callback with safe scanner initialization error code, triggered only when an error occurs.
  public init(licenseKey: String, dataCoordinators: [VGSBlinkCardDataType: VGSCardScanCoordinator], errorCallback: @escaping ((NSInteger) -> Void)) {
    self.licenseKey = licenseKey
    self.dataCoordinators = dataCoordinators
    self.errorCallback = errorCallback
  }

  public func makeUIViewController(context: Context) -> UIViewControllerType {
    UIHostingController(rootView: makeScannerView())
  }

  public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    if let hostingController = uiViewController as? UIHostingController<VGSBlinkCardScannerView> {
      hostingController.rootView = makeScannerView()
    }
  }

  // MARK: - Scan interaction events
  /// On scanner finish card recognition.
  public func onCardScanned(_ action: (() -> Void)?) -> VGSBlinkCardControllerRepresentable {
    var newRepresentable = self
    newRepresentable.onCardScanned = action
    return newRepresentable
  }

  /// On card scanning canceled by user.
  public func onCardScanCanceled(_ action: (() -> Void)?) -> VGSBlinkCardControllerRepresentable {
    var newRepresentable = self
    newRepresentable.onCardScanCanceled = action
    return newRepresentable
  }

  // MARK: - BlinkCard setting modifiers
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

  /// Set if should `showIntroductionDialog`.
  public func showIntroductionDialog(_ show: Bool) -> VGSBlinkCardControllerRepresentable {
    var newRepresentable = self
    newRepresentable.showIntroductionDialog = show
    return newRepresentable
  }

  /// Set if should `showOnboardingInfo`.
  public func showOnboardingInfo(_ show: Bool) -> VGSBlinkCardControllerRepresentable {
    var newRepresentable = self
    newRepresentable.showOnboardingInfo = show
    return newRepresentable
  }

  private var configuration: VGSBlinkCardConfiguration {
    VGSBlinkCardConfiguration(
      extractOwner: extractOwner,
      extractExpiryDate: extractExpiryDate,
      extractCvv: extractCvv,
      extractIban: extractIban,
      allowInvalidCardNumber: allowInvalidCardNumber,
      showOnboardingInfo: showOnboardingInfo,
      showIntroductionDialog: showIntroductionDialog
    )
  }

  private func makeScannerView() -> VGSBlinkCardScannerView {
    VGSBlinkCardScannerView(
      licenseKey: licenseKey,
      configuration: configuration,
      onResult: { result in
        let dataDict = VGSBlinkCardHandler.mapScanResult(result)

        for (dataType, coordinator) in dataCoordinators {
          if let scanData = dataDict[dataType] {
            coordinator.setText(scanData)
          }
          if dataType == .cardNumber {
            coordinator.trackAnalyticsEvent(scannerType: "BlinkCard")
          }
        }

        onCardScanned?()
      },
      onCancel: {
        VGSAnalyticsClient.shared.trackEvent(.scan, status: .cancel, extraData: ["scannerType": "BlinkCard"])
        onCardScanCanceled?()
      },
      onError: { error in
        let code = (error as NSError).code
        let safeCode = code == 0 ? VGSBlinkCardErrorCode.sdkInitializationFailed.rawValue : code
        VGSAnalyticsClient.shared.trackEvent(.scan, status: .failed, extraData: ["scannerType": "BlinkCard", "errorCode": safeCode])
        errorCallback(safeCode)
      }
    )
  }
}
#endif
