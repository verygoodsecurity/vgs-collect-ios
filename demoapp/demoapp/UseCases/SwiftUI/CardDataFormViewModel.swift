//
//  CardDataFormViewModel.swift
//  demoapp
//


import Foundation
import VGSCollectSDK
import Combine

class CardDataFormViewModel: ObservableObject {
    let vgsCollect = VGSCollect(id: "tnt")
    var cancellables = Set<AnyCancellable>()
    let cardNumber = ""
    let cvc = ""

  func sendDataPublisher(path: String) -> Future<VGSResponse, Never> {
      let extraData = ["card_number" : cardNumber,
                     "card_cvc": cvc]
      return vgsCollect.sendDataPublisher(path: path, extraData: extraData)
    }
}
