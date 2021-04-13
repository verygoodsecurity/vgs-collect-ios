//
//  VGSCardScanHandler.swift
//  VGSCardScanCollector
//
//  Created by Dima on 18.08.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
import CardScan
#if !COCOAPODS
import VGSCollectSDK
#endif
#if os(iOS)
import UIKit
#endif

internal class VGSCardScanHandler: NSObject, VGSScanHandlerProtocol {
    
    weak var delegate: VGSCardScanControllerDelegate?
    weak var view: UIViewController?
  
    required init(apiKey: String) {
      super.init()

			if #available(iOS 11.2, *) {
				ScanViewController.configure(apiKey: apiKey)
			} else {
				print("⚠️ Unsupported iOS version, should be iOS 11.2 or higher.")
			}
    }
    
    func presentScanVC(on viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {

			if #available(iOS 11.2, *) {
				guard let vc = ScanViewController.createViewController(withDelegate: self) else {
						print("⚠️ This device is incompatible with CardScan.")
						return
				}
				print("ScanViewController.version(): \(ScanViewController.version())")
				self.view = vc
				vc.scanDelegate = self
				viewController.present(vc, animated: animated, completion: completion)
			} else {
				print("⚠️ Unsupported iOS version, should be iOS 11.2 or higher.")
			}
    }
    
    func dismissScanVC(animated: Bool, completion: (() -> Void)?) {
        view?.dismiss(animated: animated, completion: completion)
    }
  
    static func isCompatible() -> Bool {
			if #available(iOS 11.2, *) {
				return ScanViewController.isCompatible()
			} else {
				print("⚠️ Unsupported iOS version, should be iOS 11.2 or higher.")
				return false
			}
    }
}

/// :nodoc:

@available(iOS 11.2, *)
extension VGSCardScanHandler: ScanDelegate {
  func userDidCancel(_ scanViewController: ScanViewController) {
    VGSAnalyticsClient.shared.trackEvent(.scan, status: .cancel, extraData: [ "scannerType": "Bouncer"])
    delegate?.userDidCancelScan()
  }
  
  /// :nodoc:
  func userDidScanCard(_ scanViewController: ScanViewController, creditCard: CreditCard) {
    guard let cardScanDelegate = delegate else {
      return
    }
    
    if !creditCard.number.isEmpty, let textfield = cardScanDelegate.textFieldForScannedData(type: .cardNumber) {
    
      if let form = textfield.configuration?.vgsCollector {
        VGSAnalyticsClient.shared.trackFormEvent(form.formAnalyticsDetails, type: .scan, status: .success, extraData: [ "scannerType": "Bouncer"])
      }
      textfield.setText(creditCard.number)
    }
    if let name = creditCard.name, !name.isEmpty, let textfield =
      cardScanDelegate.textFieldForScannedData(type: .name) {
      textfield.setText(name)
		}

		let expiryDateData = VGSBouncerExpirationDate(monthString: creditCard.expiryMonth, yearString: creditCard.expiryYear)

		if let defaultExpirationDate = VGSBouncerDataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationDate), let textfield = cardScanDelegate.textFieldForScannedData(type: .expirationDate) {
			textfield.setText(defaultExpirationDate)
		}

		if let longExpirationDate = VGSBouncerDataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationDateLong), let textfield = cardScanDelegate.textFieldForScannedData(type: .expirationDateLong) {
			textfield.setText(longExpirationDate)
		}

		if let expiryMonth = VGSBouncerDataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationMonth), let textfield = cardScanDelegate.textFieldForScannedData(type: .expirationMonth) {
			textfield.setText(expiryMonth)
		}

		if let expiryYear = VGSBouncerDataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationYear), let textfield = cardScanDelegate.textFieldForScannedData(type: .expirationYear) {
			textfield.setText(expiryYear)
		}

		if let expiryYearLong = VGSBouncerDataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationYearLong), let textfield = cardScanDelegate.textFieldForScannedData(type: .expirationYearLong) {
			textfield.setText(expiryYearLong)
		}
		
		cardScanDelegate.userDidFinishScan()
  }
  
  /// :nodoc:
  func userDidSkip(_ scanViewController: ScanViewController) {
    delegate?.userDidCancelScan()
  }
}
