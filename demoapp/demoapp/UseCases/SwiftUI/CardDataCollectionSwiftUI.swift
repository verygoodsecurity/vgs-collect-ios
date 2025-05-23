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
    @State private var showingBlinkCardScanner = false
    @State private var consoleMessage = ""
    /// Match scanned data with apropriate text fields.
    @State private var scanedDataCoordinators: [VGSBlinkCardDataType: VGSCardScanCoordinator] = [
            .cardNumber: VGSCardScanCoordinator(),
            .name: VGSCardScanCoordinator(),
            .cvc: VGSCardScanCoordinator(),
            .expirationDate: VGSCardScanCoordinator()
        ]

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
          .placeholder("Cardholder Name")
          .cardScanCoordinator(scanedDataCoordinators[.name]!)
          /// Track field editing events and field State
          .onEditingEvent { event in
              switch event {
              case .didBegin(let state):
                print("Editing began with state: \(state.description)")
              case .didChange(let state):
                  print("Editing changed with state: \(state.description)")
              case .didEnd(let state):
                  print("Editing ended with state: \(state.description)")
              }
          }
          /// Track field State only
          .onStateChange({ newState in
            holderTextFieldState = newState
            print("Field state changed: \(newState.description)")
          })
          .textFieldPadding(paddings)
          .border(color: (holderTextFieldState?.isValid ?? true) ? validColor : invalidColor, lineWidth: 1)
          .frame(height: 54)
        VGSCardTextFieldRepresentable(configuration: cardNumConfiguration)
          .placeholder("4111 1111 1111 1111")
          .cardScanCoordinator(scanedDataCoordinators[.cardNumber]!)
          .onStateChange { newState in
            cardTextFieldState = newState
            print(newState.description)
          }
          .cardIconSize(CGSize(width: 40, height: 20))
          .cardIconLocation(.right)
          .textFieldPadding(paddings)
          .border(color: (cardTextFieldState?.isValid ?? true) ? validColor : invalidColor, lineWidth: 1)
          .frame(height: 54)
        HStack(spacing: 20) {
          VGSExpDateTextFieldRepresentable(configuration: expDateConfiguration)
            .placeholder("MM/YY")
            .cardScanCoordinator(scanedDataCoordinators[.expirationDate]!)
            .textFieldPadding(paddings)
            .border(color: (expDateTextFieldState?.isValid ?? true) ? validColor : invalidColor, lineWidth: 1)
            .onStateChange { newState in
              expDateTextFieldState = newState
              print(newState.description)
            }
            .frame(height: 54)
          VGSCVCTextFieldRepresentable(configuration: cvcConfiguration)
            .placeholder("CVC")
            .cardScanCoordinator(scanedDataCoordinators[.cvc]!)
            .setSecureTextEntry(true)
            .cvcIconSize(CGSize(width: 30, height: 20))
            .textFieldPadding(paddings)
            .border(color: (cvcTextFieldState?.isValid ?? true) ? validColor : invalidColor, lineWidth: 1)
            .onStateChange { newState in
              cvcTextFieldState = newState
              print(newState.description)
            }
            .frame(height: 54)
        }
        HStack(spacing: 20) {
          Button(action: {
            UIApplication.shared.endEditing()
            showingBlinkCardScanner = true
          }) {
              Text("SCAN")
                  .padding()
                  .cornerRadius(8)
                  .overlay(
                      RoundedRectangle(cornerRadius: 10)
                          .stroke(Color.blue, lineWidth: 2)
                  )
          }
          .fullScreenCover(isPresented: $showingBlinkCardScanner) {
            VGSBlinkCardControllerRepresentable(licenseKey: AppCollectorConfiguration.shared.blinkCardLicenseKey!, dataCoordinators: scanedDataCoordinators) { (errorCode) in
              print(errorCode)
            }.allowInvalidCardNumber(true)
              .showOnboardingInfo(false)
              .showIntroductionDialog(false)
            .onCardScanned({
              showingBlinkCardScanner = false
            })
            .onCardScanCanceled({
              showingBlinkCardScanner = false
            })
          }
          Button(action: {
            UIApplication.shared.endEditing()
            sendData()
          }) {
              Text("UPLOAD")
                  .padding()
                  .cornerRadius(8)
                  .overlay(
                      RoundedRectangle(cornerRadius: 10)
                          .stroke(Color.blue, lineWidth: 2)
                  )
          }
        }.padding(.top, 50)
        Text("\(consoleMessage)")
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
          self.consoleMessage = "Success: \n\(response)"
          // swiftlint:enable force_try
        } else {
          self.consoleMessage = "Parsing ERROR, response: \n\(response)"
        }
        return
      case .failure(let code, _, _, let error):
        switch code {
        case 400..<499:
          // Wrong request. This also can happend when your Routs not setup yet or your <vaultId> is wrong
          self.consoleMessage = "Error: Wrong Request, code: \(code)"
          print("Error: Wrong Request, code: \(code)")
        case VGSErrorType.inputDataIsNotValid.rawValue:
          if let error = error as? VGSError {
            self.consoleMessage = "Error: Input data is not valid. Details:\n \(error)"
            print("Error: Input data is not valid. Details:\n \(error)")
          }
        default:
          self.consoleMessage = "Error: Something went wrong. Code: \(code)"
          print("Error: Something went wrong. Code: \(code)")
        }
        self.consoleMessage = "Submit request error: \(code), \(String(describing: error))"
        print("Submit request error: \(code), \(String(describing: error))")
        return
      }
    }
  }
}
