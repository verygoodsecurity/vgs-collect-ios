//
//  VGSCardScanProxy.swift
//  VGSFramework
//
//  Created by Dima on 06.01.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(CardScan)
import CardScan

internal class VGSCardScanProxy: VGSScanProviderProtocol {
    weak var delegate: VGSScanControllerDelegate?
    weak var view: UIViewController?

    func presentScan(from viewController: UIViewController) {
        guard let vc = ScanViewController.createViewController(withDelegate: self) else {
            print("This device is incompatible with CardScan")
            return
        }
        self.view = vc
        viewController.present(vc, animated: true, completion: nil)
    }

    func dismissScan(animated: Bool, completion: (() -> Void)?) {
        view?.dismiss(animated: animated, completion: completion)
    }
}

extension VGSCardScanProxy: ScanDelegate {

    func userDidSkip(_ scanViewController: ScanViewController) {
        delegate?.userDidSkipScan?()
    }

    func userDidCancel(_ scanViewController: ScanViewController) {
        delegate?.userDidCancelScan?()
    }

    func userDidScanCard(_ scanViewController: ScanViewController, creditCard: CreditCard) {
        if !creditCard.number.isEmpty, let textfield = delegate?.getFormForScanedField?(name: "cardNumber") {
            textfield.setText(creditCard.number)
        }
        if let month = creditCard.expiryMonth, !month.isEmpty,
            let year = creditCard.expiryYear, !year.isEmpty,
            let textfield = delegate?.getFormForScanedField?(name: "cardExpirationDate") {
            textfield.setText("\(month)\(year)")
        }
        if let expMonth = creditCard.expiryMonth, !expMonth.isEmpty, let textfield = delegate?.getFormForScanedField?(name: "cardExpiryMonth") {
            textfield.setText(expMonth)
        }
        if let expYear = creditCard.expiryYear, !expYear.isEmpty, let textfield = delegate?.getFormForScanedField?(name: "cardExpiryYear") {
            textfield.setText(expYear)
        }
        if let name = creditCard.name, !name.isEmpty, let textfield = delegate?.getFormForScanedField?(name: "cardHolderName") {
            textfield.setText(name)
        }
        delegate?.userDidFinishScan?()
    }
}
#endif
