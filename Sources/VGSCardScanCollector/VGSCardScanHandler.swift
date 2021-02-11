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
				viewController.present(vc, animated: true)
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
    if let month = Int(creditCard.expiryMonth ?? ""), 1...12 ~= month, let year = Int(creditCard.expiryYear ?? ""), year >= VGSCalendarUtils.currentYearShort {
     if let textfield = cardScanDelegate.textFieldForScannedData(type: .expirationDate) {
       textfield.setText("\(month)\(year)")
     }
     if let textfield = cardScanDelegate.textFieldForScannedData(type: .expirationDateLong) {
       let longYear = "20\(year)"
       textfield.setText("\(month)\(longYear)")
     }
    }
    if let month = Int(creditCard.expiryMonth ?? ""), 1...12 ~= month, let textfield = cardScanDelegate.textFieldForScannedData(type: .expirationMonth) {
       textfield.setText("\(month)")
    }
    if let year = Int(creditCard.expiryYear ?? ""), year >= VGSCalendarUtils.currentYear {
     if let textfield = cardScanDelegate.textFieldForScannedData(type: .expirationYear) {
       textfield.setText("\(year)")
     }
     if let textfield = cardScanDelegate.textFieldForScannedData(type: .expirationYearLong) {
       let longYear = "20\(year)"
       textfield.setText("\(longYear)")
     }
    }
     cardScanDelegate.userDidFinishScan()
  }
  
  /// :nodoc:
  func userDidSkip(_ scanViewController: ScanViewController) {
    delegate?.userDidCancelScan()
  }
}
