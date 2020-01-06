//
//  VGSScanProxy.swift
//  Alamofire
//
//  Created by Dima on 30.12.2019.
//

import Foundation
#if canImport(CardScan)
import CardScan
#endif

#if canImport(CardIO)
import CardIO
#endif

protocol VGSScanConfigurationProtocol {
        
}
  
public class VGSScanConfiguration {
    
    public enum ScanProvider {
        case cardIO
        case cardScan
    }
    
    public let scanProvider: ScanProvider
    
    required public init(scanProvider: ScanProvider) {
        self.scanProvider = scanProvider
    }
}

@objc public protocol VGSScanProxyDelegate {
    @objc optional func userDidFinishScan()
    @objc optional func userDidCancelScan()
    @objc optional func userDidSkipScan()
    @objc optional func getFormForScanedField(name: String) -> VGSTextField?
    //completion on present
}

internal class VGSScanProviderFactory {
    
//    static func getScanProvider(type: VGSScanConfiguration.ScanProvider) -> VGSScanManager {
//        switch type {
//        case .cardIO:
//            #if canImport(CardIO)
//            return VGSCardScanProxy()
//            #endif
//        case .cardScan:
//            #if canImport(CardScan)
//            return VGSCardScanProxy()
//            #if canImport(CardScan)
////        default:
////            fatalError("VGSScanProxy can't import \(type) framework. Please check that framework is installed")
//        }
//    }
}

public class VGSScanProxy {
    
//    internal let configuration: VGSScanConfiguration
    internal var scanProvide: VGSScanProviderProtocol?
//    public weak var delegate: VGSScanProxyDelegate?
    
    public init(with configuration: VGSScanConfiguration, delegate: VGSScanProxyDelegate) {
//        self.configuration = configuration
//        scanProvide = VGSScanProviderFactory.getScanProvider(type: .cardScan)
        #if canImport(CardScan)
        scanProvide = VGSCardScanProxy()
        scanProvide?.delegate = delegate
        #endif
    }
    
    public func presentScan(from viewController: UIViewController) {
        //check ic access to camera enabled
        scanProvide?.presentScan(from: viewController)
    }
    
    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        scanProvide?.dismissScan(animated: animated, completion: completion)
    }
}

internal protocol VGSScanProviderProtocol {
    var delegate: VGSScanProxyDelegate? { get set }
    func presentScan(from viewController: UIViewController)
    func dismissScan(animated: Bool, completion: (() -> Void)?)
}

#if canImport(CardScan)
import CardScan

internal class VGSCardScanProxy: VGSScanProviderProtocol {
    internal weak var delegate: VGSScanProxyDelegate?
    internal weak var view: UIViewController?

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
        delegate?.userDidFinishScan?()
    }
}

#endif

#if canImport(CardIO)
import CardIO

internal class VGSCardIOProxy: VGSScanProviderProtocol {
    internal weak var delegate: VGSScanProxyDelegate?
    internal weak var view: UIViewController?
    
    func presentScan(from viewController: UIViewController) {
//        guard let vc = ScanViewController.createViewController(withDelegate: self) else {
//            print("This device is incompatible with CardScan")
//            return
//        }
//        self.view = vc
//        viewController.present(vc, animated: true, completion: nil)
        if CardIOUtilities.canReadCardWithCamera {
            
        }
    }
    
    func dismissScan(animated: Bool, completion: (() -> Void)?) {
        view?.dismiss(animated: animated, completion: completion)
    }
}

extension VGSCardIOProxy: ScanDelegate {

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
        delegate?.userDidFinishScan?()
    }
}
#endif

