//
//  VGSCardIOHandler.swift
//  VGSFramework
//
//  Created by Dima on 17.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(CardIO)
import CardIO

internal class VGSCardIOHandler: NSObject, VGSScanProxyProtocol {
    var delegate: VGSScanControllerDelegate?
    weak var view: UIViewController?

    func presentScanVC(from viewController: UIViewController, animated: Bool, completion: (() -> Void?)) {
        guard let vc = CardIOPaymentViewController(paymentDelegate: self, scanningEnabled: true) else {
            print("This device is incompatible with CardIO")
            return
        }
        vc.modalPresentationStyle = .overCurrentContext
        self.view = vc
        viewController.present(vc, animated: animated, completion: completion)
    }
    
    func pushScanVC(from viewController: UIViewController, animated: Bool) {
        guard let vc = CardIOPaymentViewController(paymentDelegate: self, scanningEnabled: true) else {
            print("This device is incompatible with CardIO")
            return
        }
        self.view = vc
        viewController.push(vc, animated: animated)
    }

    func dismissScan(animated: Bool, completion: (() -> Void)?) {
        view?.dismiss(animated: animated, completion: completion)
    }
}

extension VGSCardIOHandler: CardIOPaymentViewControllerDelegate {
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        delegate?.userDidCancelScan?()
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        guard let cardInfo = cardInfo, let cardIOdelegate = delegate as? VGSCardIOScanControllerDelegate else {
            delegate?.userDidFinishScan?()
            return
        }
        if !cardInfo.cardNumber.isEmpty, let textfield = cardIOdelegate.textFieldForScannedData(type: .cardNumber) {
            textfield.setText(cardInfo.cardNumber)
        }
        if  1...12 ~= Int(cardInfo.expiryMonth), cardInfo.expiryYear >= 2020,
            let textfield = cardIOdelegate.textFieldForScannedData(type: .expirationDate) {
            let yy = "\(cardInfo.expiryYear)".suffix(2)
            let monthString = Int(cardInfo.expiryMonth) < 10 ? "0\(cardInfo.expiryMonth)" : "\(cardInfo.expiryMonth)"
            textfield.setText("\(monthString)\(yy)")
        }
        if 1...12 ~= Int(cardInfo.expiryMonth), let textfield = cardIOdelegate.textFieldForScannedData(type: .expirationMonth) {
            let monthString = Int(cardInfo.expiryMonth) < 10 ? "0\(cardInfo.expiryMonth)" : "\(cardInfo.expiryMonth)"
            textfield.setText(monthString)
        }
        if cardInfo.expiryYear >= 2020, let textfield = cardIOdelegate.textFieldForScannedData(type: .expirationYear) {
            let yy = String("\(cardInfo.expiryYear)".suffix(2))
            textfield.setText(yy)
        }
        if let cvc = cardInfo.cvv, !cvc.isEmpty, let textfield = cardIOdelegate.textFieldForScannedData(type: .cvc) {
            textfield.setText(cvc)
        }
        cardIOdelegate.userDidFinishScan?()
    }
}
#endif

