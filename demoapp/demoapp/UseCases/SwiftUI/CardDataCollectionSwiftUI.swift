//
//  CardDataCollectionSwiftUI.swift
//  demoapp
//

import SwiftUI
import VGSCollectSDK

struct CardDataCollectionSwiftUI: View {
    let vgsCollect = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)
  
    // MARK: - State
    @State private var holderTextFieldState: VGSTextFieldState?
    @State private var cardTextFieldState: VGSCardState?
    @State private var expDateTextFieldState: VGSTextFieldState?
    @State private var cvcTextFieldState: VGSTextFieldState?

    // MARK: - Textfield UI attributes
    let paddings = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
    let validColor = UIColor.lightGray
    let invalidColor = UIColor.red
        
    // MARK: - Build View
    var body: some View {
      
      // MARK: - Textfield Configuration
      var holderNameConfiguration: VGSConfiguration {
        let config = VGSConfiguration(collector: vgsCollect, fieldName: "cardHolder_name")
        config.type = .cardHolderName
        return config
      }
      
      var cardNumConfiguration: VGSConfiguration {
        let config = VGSConfiguration(collector: vgsCollect, fieldName: "card_number")
        config.type = .cardNumber
        return config
      }
      
      var expDateConfiguration: VGSExpDateConfiguration {
        let config = VGSExpDateConfiguration(collector: vgsCollect, fieldName: "card_expirationDate")
        config.type = .expDate
        return config
      }
      var cvcConfiguration: VGSConfiguration {
        let config = VGSConfiguration(collector: vgsCollect, fieldName: "card_cvc")
        config.type = .cvc
        return config
      }
      
      return VStack(spacing: 8) {
        VGSTextFieldRepresentable(configuration: holderNameConfiguration)
          .placeholder("Cardholder name")
          .onEditingStart {
            print("- Cardholder name onEditingStart")
          }
          .onEditingEnd {
            print("- Cardholder name onEditingEnd")
          }
          .textFieldPadding(paddings)
          .border(color: (holderTextFieldState?.isValid ?? true) ? validColor : invalidColor, lineWidth: 1)
          .frame(height: 54)
        VGSCardTextFieldRepresentable(configuration: cardNumConfiguration)
          .placeholder("4111 1111 1111 1111")
          .onStateChange { newState in
            cardTextFieldState = newState
            print(newState.isValid)
          }
          .cardIconSize(CGSize(width: 40, height: 20))
          .cardIconLocation(.right)
          .textFieldPadding(paddings)
          .border(color: (cardTextFieldState?.isValid ?? true) ? validColor : invalidColor, lineWidth: 1)
          .frame(height: 54)
        HStack(spacing: 20) {
          VGSExpDateTextFieldRepresentable(configuration: expDateConfiguration)
            .placeholder("10/25")
            .textFieldPadding(paddings)
            .border(color: (expDateTextFieldState?.isValid ?? true) ? validColor : invalidColor, lineWidth: 1)
            .frame(height: 54)
          VGSCVCTextFieldRepresentable(configuration: cvcConfiguration)
            .placeholder("CVC/CVV")
            .setSecureTextEntry(true)
            .cvcIconSize(CGSize(width: 30, height: 20))
            .textFieldPadding(paddings)
            .border(color: (cvcTextFieldState?.isValid ?? true) ? validColor : invalidColor, lineWidth: 1)
            .frame(height: 54)
        }
        Button(action: {
          UIApplication.shared.endEditing()
          sendData()
        }) {
            Text("Send data")
                .padding()
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                )
        }.padding(.top, 50)
      }.padding(.leading, 20)
       .padding(.trailing, 20)
  }
  
  private func sendData() {
    /// send extra data
    var extraData = [String: Any]()
    extraData["customKey"] = "Custom Value"

    /// Send Data from VGS textfield to Vault
    vgsCollect.sendData(path: "/post", extraData: extraData) { (response) in
      
      switch response {
      case .success(_, let data, _):
        if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          // swiftlint:disable force_try
          let response = (String(data: try! JSONSerialization.data(withJSONObject: jsonData["json"]!, options: .prettyPrinted), encoding: .utf8)!)
          print("Success: \n\(response)")
          // swiftlint:enable force_try
          }
          return
      case .failure(let code, _, _, let error):
        switch code {
        case 400..<499:
          // Wrong request. This also can happend when your Routs not setup yet or your <vaultId> is wrong
          print("Error: Wrong Request, code: \(code)")
        case VGSErrorType.inputDataIsNotValid.rawValue:
          if let error = error as? VGSError {
            print("Error: Input data is not valid. Details:\n \(error)")
          }
        default:
                    print("Error: Something went wrong. Code: \(code)")
        }
        print("Submit request error: \(code), \(String(describing: error))")
        return
      }
    }
  }
}
