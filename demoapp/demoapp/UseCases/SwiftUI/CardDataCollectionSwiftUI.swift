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
    @State private var cardTextFieldState: VGSTextFieldState? = nil
  
    let paddings = UIEdgeInsets(top: 2,left: 8,bottom: 2,right: 8)
    var borderColor: UIColor {
      cardTextFieldState?.isValid ?? true ? .lightGray : .red
    }
  
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
      return VStack(spacing: 8) {
      VGSCardTextFieldRepresentable(configuration: cardNumConfiguration)
        .placeholder("4111 1111 1111 1111")
        .onStateChange { newState in
          cardTextFieldState = newState
          print(newState.isValid)
        }
          .cardIconSize(CGSize(width: 40, height: 20))
        .cardIconLocation(.right)
        .padding(paddings)
        .border(color: borderColor, lineWidth: 1)
        .frame(height: 50)
        .padding()
      VGSTextFieldRepresentable(configuration: expDateConfiguration)
        .onEditingEnd{
          print("onEditingEnd")
        }
        .onEditingStart {
          print("onEditingStart")

        }
        .padding(paddings)
        .placeholder("10/25")
        .frame(height: 34)
        .padding()
      
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
