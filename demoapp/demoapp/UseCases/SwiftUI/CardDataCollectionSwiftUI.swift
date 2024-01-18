//
//  CardDataCollectionSwiftUI.swift
//  demoapp
//
//  Created by Dmytro on 12.01.2024.
//  Copyright © 2024 Very Good Security. All rights reserved.
//

import SwiftUI
import VGSCollectSDK

struct CardDataCollectionSwiftUI: View {
    let vgsCollect = VGSCollect(id: "tnt")
    let borderColor = Color.gray
    @State private var cardTextFieldState: VGSTextFieldState? = nil
  
    var cardNumConfiguration: VGSConfiguration {
      let config = VGSConfiguration(collector: vgsCollect, fieldName: "cardNumber")
      config.type = .cardNumber
      return config
    }
  
    var expDateConfiguration: VGSConfiguration {
      let config = VGSConfiguration(collector: vgsCollect, fieldName: "expDate")
      config.type = .expDate
      return config
    }

    var body: some View {
      return VStack(spacing: 20) {
      VGSTextFieldRepresentable(configuration: cardNumConfiguration)
        .placeholder("4111 1111 1111 1111")
        .onStateChange { newState in
          cardTextFieldState = newState
          print(newState.isValid)
        }
        .setSecureTextEntry(true)
        .padding(UIEdgeInsets(top: 2,left: 8,bottom: 2,right: 8))
        .frame(height: 34)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke((cardTextFieldState?.isValid ?? false) ? borderColor : .red, lineWidth: 1)
        ).padding()
      VGSTextFieldRepresentable(configuration: expDateConfiguration)
        .onEditingEnd{
          print("onEditingEnd")
        }
        .onEditingStart {
          print("onEditingStart")

        }
        .placeholder("10/25")
        .frame(height: 34)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(borderColor, lineWidth: 1)
        ).padding()

        
      Button(action: sendData) {
        Text("Submit")
      }
    }
  }
  
  private func sendData() {
    print(vgsCollect.textFields)
    vgsCollect.sendData(path: "post") { response in
      print(response)
    }
  }
}
