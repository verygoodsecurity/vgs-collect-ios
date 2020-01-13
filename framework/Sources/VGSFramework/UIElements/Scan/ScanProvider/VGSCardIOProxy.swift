//
//  VGSCardIOProxy.swift
//  VGSFramework
//
//  Created by Dima on 13.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(CardIO)
import CardIO

internal class VGSCardIOProxy: NSObject, VGSScanProviderProtocol {
    weak var delegate: VGSScanControllerDelegate?
    weak var view: UIViewController?

    func presentScan(from viewController: UIViewController) {
        guard let vc = CardIOPaymentViewController(paymentDelegate: self, scanningEnabled: true) else {
            print("This device is incompatible with CardIO")
            return
        }
        vc.modalPresentationStyle = .overCurrentContext
        self.view = vc
        viewController.present(vc, animated: true, completion: nil)
    }

    func dismissScan(animated: Bool, completion: (() -> Void)?) {
        view?.dismiss(animated: animated, completion: completion)
    }
}

extension VGSCardIOProxy: CardIOPaymentViewControllerDelegate {
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        delegate?.userDidCancelScan?()
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        guard let cardInfo = cardInfo else {
            delegate?.userDidFinishScan?()
            return
        }
        if !cardInfo.cardNumber.isEmpty, let textfield = delegate?.getFormForScanedField?(name: "cardNumber") {
            textfield.setText(cardInfo.cardNumber)
        }
        if  1...12 ~= Int(cardInfo.expiryMonth), cardInfo.expiryYear >= 2020,
            let textfield = delegate?.getFormForScanedField?(name: "cardExpirationDate") {
            let yy = "\(cardInfo.expiryYear)".suffix(2)
            textfield.setText("\(cardInfo.expiryMonth)\(yy)")
        }
        if 1...12 ~= Int(cardInfo.expiryMonth), let textfield = delegate?.getFormForScanedField?(name: "cardExpiryMonth") {
            textfield.setText("\(cardInfo.expiryMonth)")
        }
        if cardInfo.expiryYear >= 2020, let textfield = delegate?.getFormForScanedField?(name: "cardExpiryYear") {
            let yy = String("\(cardInfo.expiryYear)".suffix(2))
            textfield.setText(yy)
        }
        if let cvv = cardInfo.cvv, !cvv.isEmpty, let textfield = delegate?.getFormForScanedField?(name: "cardCVV") {
            textfield.setText(cvv)
        }
        delegate?.userDidFinishScan?()
    }
}
#endif
