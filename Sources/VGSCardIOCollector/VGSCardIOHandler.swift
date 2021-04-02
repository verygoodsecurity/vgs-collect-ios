//
//  VGSCardIOHandler.swift
//  VGSCollectSDK
//
//  Created by Dima on 17.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
import CardIO
import UIKit
import AVFoundation.AVCaptureDevice

#if !COCOAPODS
import VGSCollectSDK
#endif

internal class VGSCardIOHandler: NSObject, VGSScanHandlerProtocol {
    
    weak var delegate: VGSCardIOScanControllerDelegate?
    weak var view: UIViewController?
    var cameraPosition: AVCaptureDevice.Position?
    var suppressScanConfirmation = false
    var disableManualEntryButtons = false
    var languageOrLocale: String?
  
    func presentScanVC(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let vc = CardIOPaymentViewController(paymentDelegate: self, scanningEnabled: true, preferredDevicePosition: cameraPosition ?? .unspecified) else {
            print("This device is not compatible with CardIO")
            return
        }
        vc.hideCardIOLogo = true
        vc.suppressScanConfirmation = suppressScanConfirmation
        vc.disableManualEntryButtons = disableManualEntryButtons
        vc.languageOrLocale = languageOrLocale
        vc.modalPresentationStyle = .overCurrentContext
        self.view = vc
        viewController.present(vc, animated: animated, completion: completion)
    }
    
    func dismissScanVC(animated: Bool, completion: (() -> Void)?) {
        view?.dismiss(animated: animated, completion: completion)
    }
}

/// :nodoc:
extension VGSCardIOHandler: CardIOPaymentViewControllerDelegate {
    
    /// :nodoc:
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
      VGSAnalyticsClient.shared.trackEvent(.scan, status: .cancel, extraData: [ "scannerType": "CardIO"])
        delegate?.userDidCancelScan()
    }
    
    /// :nodoc:
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        guard let cardInfo = cardInfo, let cardIOdelegate = delegate else {
            delegate?.userDidFinishScan()
            return
        }

        if !cardInfo.cardNumber.isEmpty, let textfield = cardIOdelegate.textFieldForScannedData(type: .cardNumber) {
            if let form = textfield.configuration?.vgsCollector {
              VGSAnalyticsClient.shared.trackFormEvent(form.formAnalyticsDetails, type: .scan, status: .success, extraData: [ "scannerType": "CardIO"])
            }
            textfield.setText(cardInfo.cardNumber)
        }

			let expiryDateData = VGSCardIOExpirationDate(month: cardInfo.expiryMonth, year: cardInfo.expiryYear)

			if let defaultExpirationDate = VGSCardIODataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationDate), let textfield = cardIOdelegate.textFieldForScannedData(type: .expirationDate) {
				textfield.setText(defaultExpirationDate)
			}

			if let longExpirationDate = VGSCardIODataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationDateLong), let textfield = cardIOdelegate.textFieldForScannedData(type: .expirationDateLong) {
				textfield.setText(longExpirationDate)
			}

			if let expiryMonth = VGSCardIODataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationMonth), let textfield = cardIOdelegate.textFieldForScannedData(type: .expirationMonth) {
				textfield.setText(expiryMonth)
			}

			if let expiryYear = VGSCardIODataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationYear), let textfield = cardIOdelegate.textFieldForScannedData(type: .expirationYear) {
				textfield.setText(expiryYear)
			}

			if let expiryYearLong = VGSCardIODataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationYearLong), let textfield = cardIOdelegate.textFieldForScannedData(type: .expirationYearLong) {
				textfield.setText(expiryYearLong)
			}

			if let cvc = cardInfo.cvv, !cvc.isEmpty, let textfield = cardIOdelegate.textFieldForScannedData(type: .cvc) {
            textfield.setText(cvc)
			}

			cardIOdelegate.userDidFinishScan()
    }
}
