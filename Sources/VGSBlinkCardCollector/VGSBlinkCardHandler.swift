//
//  VGSBlinkCardHandler.swift
//  VGSBlinkCardCollector
//


import Foundation
import BlinkCard
#if !COCOAPODS
import VGSCollectSDK
#endif
#if os(iOS)
import UIKit
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

    /// Initialization
    /// - Parameters:
    ///   - licenseKey: key required for BlinkCard  SDK usage.
    ///   - errorCallback: Error callback with Int error code(represents `MBCLicenseError` enum), triggered only when error occured.
    required init(licenseKey: String, errorCallback: @escaping ((NSInteger) -> Void)) {
      super.init()
      MBCMicroblinkSDK.shared().setLicenseKey(licenseKey) { error in
        VGSAnalyticsClient.shared.trackEvent(.scan, status: .failed, extraData: ["scannerType": "BlinkCard", "errorCode": error])
        errorCallback(error.rawValue)
      }
    }
    
    /// Setup BlinlCard params and present scanner.
    func presentScanVC(on viewController: UIViewController, animated: Bool, modalPresentationStyle: UIModalPresentationStyle, completion: (() -> Void)?) {
       // Create BlinkCard settings
       let settings : MBCBlinkCardOverlaySettings = MBCBlinkCardOverlaySettings()
       settings.enableEditScreen = false
       // Crate recognizer collection
       let recognizerList = [cardRecognizer]
       let recognizerCollection : MBCRecognizerCollection = MBCRecognizerCollection(recognizers: recognizerList)
        // Create  overlay view controller
       let blinkCardOverlayViewController = MBCBlinkCardOverlayViewController(settings: settings, recognizerCollection: recognizerCollection, delegate: self)
        // Create recognizer view controller with wanted overlay view controller
       let recognizerRunneViewController : UIViewController = MBCViewControllerFactory.recognizerRunnerViewController(withOverlayViewController: blinkCardOverlayViewController)!
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
      // card number
      let number = result.cardNumber.trimmingCharacters(in: .whitespacesAndNewlines)
      if !number.isEmpty, let textfield = blinkCardDelegate.textFieldForScannedData(type: .cardNumber) {
        if let form = textfield.configuration?.vgsCollector {
          VGSAnalyticsClient.shared.trackFormEvent(form.formAnalyticsDetails, type: .scan, status: .success, extraData: [ "scannerType": "BlinkCard"])
        }
        textfield.setText(number)
      }
      // card holder name
      let name = result.owner
      if !name.isEmpty, let textfield =
        blinkCardDelegate.textFieldForScannedData(type: .name) {
        textfield.setText(name)
      }
      // cvv
      let cvv = result.cvv
      if !cvv.isEmpty, let textfield =
        blinkCardDelegate.textFieldForScannedData(type: .cvc) {
        textfield.setText(cvv)
      }
      // exp.date
      let month = result.expiryDate.month
      let year = result.expiryDate.year
      let date = VGSBlinkCardExpirationDate(month, year: year)
      if let textField = blinkCardDelegate.textFieldForScannedData(type: .expirationDate) {
        textField.setText(date.mapDefaultExpirationDate())
      }
      if let textField = blinkCardDelegate.textFieldForScannedData(type: .expirationDateLong) {
        textField.setText(date.mapLongExpirationDate())
      }
      if let textField = blinkCardDelegate.textFieldForScannedData(type: .expirationDateShortYearThenMonth) {
        textField.setText(date.mapExpirationDateWithShortYearFirst())
      }
      if let textField = blinkCardDelegate.textFieldForScannedData(type: .expirationDateLongYearThenMonth) {
        textField.setText(date.mapLongExpirationDateWithLongYearFirst())
      }
      if let textField = blinkCardDelegate.textFieldForScannedData(type: .expirationYear) {
        textField.setText(String(date.shortYear))
      }
      if let textField = blinkCardDelegate.textFieldForScannedData(type: .expirationYearLong) {
        textField.setText(String(date.year))
      }
      if let textField = blinkCardDelegate.textFieldForScannedData(type: .expirationMonth) {
        textField.setText(date.monthString)
      }
      // notify scan is finished
      self?.delegate?.userDidFinishScan()
    }
  }
  
  /// When user tap close button.
  func blinkCardOverlayViewControllerDidTapClose(_ blinkCardOverlayViewController: MBCBlinkCardOverlayViewController) {
    VGSAnalyticsClient.shared.trackEvent(.scan, status: .cancel, extraData: [ "scannerType": "BlinkCard"])
    delegate?.userDidCancelScan()
  }
}
