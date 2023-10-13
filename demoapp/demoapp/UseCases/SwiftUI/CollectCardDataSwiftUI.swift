//
//  CollectCardDataSwiftUI.swift
//  demoapp
//


import SwiftUI
import Combine
import VGSCollectSDK

struct CollectCardDataSwiftUI: View {
    @ObservedObject var viewModel = CardDataFormViewModel()
  
    let borderColor = Color.gray
    var cancellables = Set<AnyCancellable>()
  
    var body: some View {
      return VStack(spacing: 20) {
        VGSTextFieldSwiftUI(configuration: VGSConfiguration(collector: viewModel.vgsCollect, fieldName: "card_number"), placeholder: "Card Number")
          .frame(height: 34)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(borderColor, lineWidth: 1)
          )
        
        VGSTextFieldSwiftUI(configuration: VGSConfiguration(collector: viewModel.vgsCollect, fieldName: "card_cvc"), placeholder: "CVC").frame(height: 34)
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(borderColor, lineWidth: 1)
          )
          Button(action: sendData) {
            Text("Submit")
          }
      }
        .padding()
      }
  
  
  private func sendData() {
    viewModel.sendDataPublisher(path: "post")
      .sink(
        receiveCompletion: { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        },
        receiveValue: { response in
            print("Response: \(response)")
        }
      ).store(in: &viewModel.cancellables)
  }
}

struct CollectCardDataSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
      CollectCardDataSwiftUI()
    }
}
