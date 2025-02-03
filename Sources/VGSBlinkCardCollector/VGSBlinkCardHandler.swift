//
//  VGSBlinkCardHandler.swift
//  VGSBlinkCardCollector
//

import Foundation
import VGSClientSDKAnalytics
#if os(iOS)
import UIKit
#endif

#if canImport(BlinkCard)
import BlinkCard
#if !COCOAPODS
import VGSCollectSDK
#endif

/// BlinkCard wrapper, manages communication between public API and BlinkCard.
@available(iOS 13.0, *)
internal class VGSBlinkCardHandler: NSObject, VGSScanHandlerProtocol {
    /// VGS BlinkCard Controller Delegate.
    weak var delegate: VGSBlinkCardControllerDelegate?
    /// BlinkCard scanner UIViewController.
    weak var view: UIViewController?
    /// MBCBlinkCardRecognizer.
    lazy var cardRecognizer: MBCBlinkCardRecognizer = {
      return MBCBlinkCardRecognizer()
    }()
    /// MBCBlinkCardOverlaySettings.
    lazy var overlaySettings : MBCBlinkCardOverlaySettings = {
      let settings: MBCBlinkCardOverlaySettings = MBCBlinkCardOverlaySettings()
      settings.enableEditScreen = false
      return settings
    }()

    /// Initialization
    /// - Parameters:
    ///   - licenseKey: key required for BlinkCard  SDK usage.
    ///   - errorCallback: Error callback with Int error code(represents `MBCLicenseError` enum), triggered only when error occured.
    required init(licenseKey: String, errorCallback: @escaping ((NSInteger) -> Void)) {
      super.init()
      MBCMicroblinkSDK.shared().setLicenseKey(licenseKey) { error in
        VGSAnalyticsClient.shared.capture(event: VGSAnalyticsEvent.Scan(status: VGSAnalyticsStatus.failed, scannerType: VGSAnalyticsScannerType.blinkCard, errorCode: Int32(error.rawValue)))
        errorCallback(error.rawValue)
      }
    }
    
    /// Setup BlinlCard params and present scanner.
    func presentScanVC(on viewController: UIViewController, animated: Bool, modalPresentationStyle: UIModalPresentationStyle, completion: (() -> Void)?) {
       // Crate recognizer collection
       let recognizerList = [cardRecognizer]
       let recognizerCollection: MBCRecognizerCollection = MBCRecognizerCollection(recognizers: recognizerList)
        // Create  overlay view controller
      let blinkCardOverlayViewController = MBCBlinkCardOverlayViewController(settings: overlaySettings, recognizerCollection: recognizerCollection, delegate: self)
        // Create recognizer view controller with wanted overlay view controller
       let recognizerRunneViewController: UIViewController = MBCViewControllerFactory.recognizerRunnerViewController(withOverlayViewController: blinkCardOverlayViewController)!
        recognizerRunneViewController.modalPresentationStyle = modalPresentationStyle
        self.view = recognizerRunneViewController
        // Present the recognizer runner view controller
        viewController.present(recognizerRunneViewController, animated: true, completion: completion)
    }

    /// Setup BlinkCard params and present scanner.
    func dismissScanVC(animated: Bool, completion: (() -> Void)?) {
        view?.dismiss(animated: animated, completion: completion)
    }
  
    /// Set custom localization fileName.
    static func setCustomLocalization(fileName: String) {
      MBCMicroblinkApp.shared().customLocalizationFileName = fileName
    }
}

/// :nodoc:
@available(iOS 13.0, *)
extension VGSBlinkCardHandler: MBCBlinkCardOverlayViewControllerDelegate {

  /// When BlinkCard finish card recognition.
  func blinkCardOverlayViewControllerDidFinishScanning(_ blinkCardOverlayViewController: MBCBlinkCardOverlayViewController, state: MBCRecognizerResultState) {
    // pause scanning
    blinkCardOverlayViewController.recognizerRunnerViewController?.pauseScanning()
    // send results in main thread
    DispatchQueue.main.async { [weak self] in
      // get scan result and delegate
      guard let result = self?.cardRecognizer.result,
            let blinkCardDelegate = self?.delegate else { return }
        
      let dataDict = Self.mapScanResult(result)
      
      for dataType in VGSBlinkCardDataType.allCases {
        if let textfield = blinkCardDelegate.textFieldForScannedData(type: dataType), let value = dataDict[dataType] {
          textfield.setText(value)
          /// analytics event, send once
          if dataType == .cardNumber {
            if let form = textfield.configuration?.vgsCollector {
              VGSAnalyticsClient.shared.capture(
                form.formAnalyticsDetails,
                event: VGSAnalyticsEvent.Scan(status: VGSAnalyticsStatus.ok, scannerType: VGSAnalyticsScannerType.blinkCard))
            }
          }
        }
      }
      // notify scan is finished
      self?.delegate?.userDidFinishScan()
    }
  }
  
  /// When user tap close button.
  func blinkCardOverlayViewControllerDidTapClose(_ blinkCardOverlayViewController: MBCBlinkCardOverlayViewController) {
    VGSAnalyticsClient.shared.capture(event: VGSAnalyticsEvent.Scan(status: VGSAnalyticsStatus.canceled, scannerType: VGSAnalyticsScannerType.blinkCard))
    delegate?.userDidCancelScan()
  }
  
  static func mapScanResult(_ result: MBCBlinkCardRecognizerResult) -> [VGSBlinkCardDataType: String] {
    var data = [VGSBlinkCardDataType: String]()
  
    let number = result.cardNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    if !number.isEmpty {data[.cardNumber] = number}
    
    let name = result.owner
    if !name.isEmpty {data[.name] = name}
    
    let cvv = result.cvv
    if !cvv.isEmpty {data[.cvc] = cvv}

    let month = result.expiryDate.month
    let year = result.expiryDate.year
    let date = VGSBlinkCardExpirationDate(month, year: year)
    
    data[.expirationDate] = date.mapDefaultExpirationDate()
    data[.expirationDateLong] = date.mapLongExpirationDate()
    data[.expirationDateShortYearThenMonth] = date.mapExpirationDateWithShortYearFirst()
    data[.expirationDateLongYearThenMonth] = date.mapLongExpirationDateWithLongYearFirst()
    data[.expirationYear] = String(date.shortYear)
    data[.expirationYearLong] = String(date.year)
    data[.expirationMonth] = (date.monthString)
    return data
  }
}
#endif
