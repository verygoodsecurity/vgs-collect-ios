//
//  ContentView.swift
//  VGSCollectSwiftUIDemoApp
//
//  Created by Dmytro on 18.09.2023.
//

import SwiftUI
import VGSCollectSDK

struct ContentView: View {
  @State private var validColor = Color.green
  @State private var invalidColor = Color.red
  
  let collector = VGSCollect.init(id: "tnt", environment: .sandbox)
  var configuration: VGSConfiguration

  init() {
    self.configuration = VGSConfiguration(collector: collector, fieldName: "cardHolder")
    self.configuration.validationRules = VGSValidationRuleSet(rules: [VGSValidationRuleLength.init(min: 5, error: VGSValidationErrorType.length.rawValue)])
  }
  
    var body: some View {
        VStack {
          Text("Card data")
          VGSTextFieldSwiftUI(configuration: configuration).background(
            RoundedRectangle(cornerRadius: 8)
              .stroke( .gray, lineWidth: 2))
            Button(action: sendData) {
              Text("Submit")
          }
        }
        .padding()
    }
  
  func sendData() {
    collector.sendData(path: "post") { response in
      print(response)
    }
  }
}
