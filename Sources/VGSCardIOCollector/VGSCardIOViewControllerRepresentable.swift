//
//  VGSCardIOViewControllerRepresentable.swift
//  VGSCardIOCollector
//
//  Created by Dmytro on 25.01.2024.
//  Copyright © 2024 VGS. All rights reserved.
//

import Foundation
import SwiftUI
import CardIO

#if !COCOAPODS
import VGSCollectSDK
#endif

public struct VGSCardIOViewControllerRepresentable: UIViewControllerRepresentable {
  
    var fieldMappingPolicy = [CradIODataType: VGSTextField]()
    
    public var onCardScanned: (() -> Void)?
  
    public init(fieldMappingPolicy: [CradIODataType: VGSTextField] = [CradIODataType: VGSTextField]()) {
      self.fieldMappingPolicy = fieldMappingPolicy
    }
  
    public func makeUIViewController(context: Context) -> CardIOPaymentViewController {
        let vc = CardIOPaymentViewController(paymentDelegate: context.coordinator, scanningEnabled: true, preferredDevicePosition: .unspecified)
        vc?.hideCardIOLogo = true
        return vc!
    }
  
    public func updateUIViewController(_ uiViewController: CardIOPaymentViewController, context: Context) {
      
    }
  
    public func onCardScanned(_ action: (() -> Void)?) -> VGSCardIOViewControllerRepresentable {
      var newRepresentable = self
      newRepresentable.onCardScanned = action
      return newRepresentable
    }
  
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
  
    public class Coordinator: NSObject, CardIOPaymentViewControllerDelegate {
      var parent: VGSCardIOViewControllerRepresentable

      init(_ parent: VGSCardIOViewControllerRepresentable) {
          self.parent = parent
      }
      
      public func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        self.parent.onCardScanned?()
      }
      
      public func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        guard let cardInfo = cardInfo else {
            self.parent.onCardScanned?()
            return
        }
        let fields = parent.fieldMappingPolicy

        if !cardInfo.cardNumber.isEmpty, let textfield = fields[CradIODataType.cardNumber] {
            if let form = textfield.configuration?.vgsCollector {
              VGSAnalyticsClient.shared.trackFormEvent(form.formAnalyticsDetails, type: .scan, status: .success, extraData: [ "scannerType": "CardIO"])
            }
            textfield.setText(cardInfo.cardNumber)
        }

        let expiryDateData = VGSCardIOExpirationDate(month: cardInfo.expiryMonth, year: cardInfo.expiryYear)
        
          if let defaultExpirationDate = VGSCardIODataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationDate), let textfield = fields[CradIODataType.expirationDate] {
            textfield.setText(defaultExpirationDate)
          }
    
          if let longExpirationDate = VGSCardIODataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationDateLong), let textfield = fields[CradIODataType.expirationDateLong] {
            textfield.setText(longExpirationDate)
          }
    
          if let shortExpirationDateWithYearFirst = VGSCardIODataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationDateShortYearThenMonth), let textfield = fields[CradIODataType.expirationDateShortYearThenMonth] {
            textfield.setText(shortExpirationDateWithYearFirst)
          }
    
          if let longExpirationDateWithYearFirst = VGSCardIODataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationDateLongYearThenMonth), let textfield = fields[CradIODataType.expirationDateLongYearThenMonth] {
            textfield.setText(longExpirationDateWithYearFirst)
          }
    
          if let expiryMonth = VGSCardIODataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationMonth), let textfield = fields[CradIODataType.expirationMonth] {
            textfield.setText(expiryMonth)
          }
    
          if let expiryYear = VGSCardIODataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationYear), let textfield = fields[CradIODataType.expirationYear] {
            textfield.setText(expiryYear)
          }
    
          if let expiryYearLong = VGSCardIODataMapUtils.mapCardExpirationData(expiryDateData, scannedDataType: .expirationYearLong), let textfield = fields[CradIODataType.expirationYearLong] {
            textfield.setText(expiryYearLong)
          }
    
          if let cvc = cardInfo.cvv, !cvc.isEmpty, let textfield = fields[CradIODataType.cvc] {
                textfield.setText(cvc)
          }

        self.parent.onCardScanned?()
      }
    }
}
