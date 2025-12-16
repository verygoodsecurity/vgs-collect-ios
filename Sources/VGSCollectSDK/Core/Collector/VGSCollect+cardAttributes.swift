//
//  VGSCollect+cardAttributes.swift
//  VGSCollectSDK
//
//  Created by AI Agent on 12/09/2025.
//

import Foundation

// MARK: - Card Attributes
extension VGSCollect {
  
  /**
   Fetches card attributes for a card number field using the first 11 digits.
   
   This method is available only for fields with type `.cardNumber`. It extracts the first 11 digits
   of the card number and sends a request to the card attributes server to retrieve card metadata.
   
   - Parameters:
      - fieldName: The field name of the card number field.
      - completion: Response completion block, returns `VGSResponse`.
   
   - Throws:
      - `VGSError` with type `.invalidFieldType` if the field is not of type `.cardNumber`.
      - `VGSError` with type `.incompleteCardNumber` if the card number has fewer than 11 digits.
   
   - Note:
   The card number must have at least 11 digits. If the card number is incomplete, the completion
   block will be called with a `.failure` response containing a `VGSError` of type `.incompleteCardNumber`.
   
   Usage:
   ```swift
   collector.getCardAttributes(fieldName: "card_number") { response in
     switch response {
     case .success(let code, let data, _):
       if let data = data,
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
         print("Card attributes: \(json)")
       }
     case .failure(let code, _, _, let error):
       print("Error: \(error?.localizedDescription ?? "Unknown error")")
     }
   }
   ```
   */
  public func getCardAttributes(fieldName: String, completion: @escaping (VGSResponse) -> Void) {
    // Find the field
    guard let field = getTextField(fieldName: fieldName) else {
      let error = VGSError(type: .invalidFieldType,
                          userInfo: VGSErrorInfo(key: VGSSDKErrorInputDataIsNotValid,
                                                description: "Field with name '\(fieldName)' not found",
                                                extraInfo: [:]))
      completion(.failure(error.code, nil, nil, error))
      return
    }
    
    // Validate field type is .cardNumber
    guard field.fieldType == .cardNumber else {
      let error = VGSError(type: .invalidFieldType,
                          userInfo: VGSErrorInfo(key: VGSSDKErrorInputDataIsNotValid,
                                                description: "Field '\(fieldName)' must be of type .cardNumber",
                                                extraInfo: [:]))
      completion(.failure(error.code, nil, nil, error))
      return
    }
    
    // Get the raw card number (without formatting characters)
    guard let cardNumber = field.textField.getSecureRawText, !cardNumber.isEmpty else {
      let error = VGSError(type: .incompleteCardNumber,
                          userInfo: VGSErrorInfo(key: VGSSDKErrorInputDataIsNotValid,
                                                description: "Card number is empty",
                                                extraInfo: [:]))
      completion(.failure(error.code, nil, nil, error))
      return
    }
    
    // Validate card number has at least 11 digits
    guard cardNumber.count >= 11 else {
      let error = VGSError(type: .incompleteCardNumber,
                          userInfo: VGSErrorInfo(key: VGSSDKErrorInputDataIsNotValid,
                                                description: "Card number must have at least 11 digits. Current length: \(cardNumber.count)",
                                                extraInfo: [:]))
      completion(.failure(error.code, nil, nil, error))
      return
    }
    
    // Extract first 11 digits
    let first11Digits = String(cardNumber.prefix(11))
    
    // Log the request (without logging actual card number)
    let message = "Fetching card attributes for field '\(fieldName)'"
    let event = VGSLogEvent(level: .info, text: message)
    VGSCollectLogger.shared.forwardLogEvent(event)
    
    // Track analytics
    VGSAnalyticsClient.shared.trackFormEvent(self.formAnalyticsDetails,
                                            type: .beforeSubmit,
                                            status: .success,
                                            extraData: ["action": "getCardAttributes", "fieldName": fieldName])
    
    // Fetch card attributes
    proxyAPIClient.fetchCardAttributes(cardNumberBin: first11Digits) { [weak self] response in
      guard let self = self else { return }
      
      // Track analytics
      switch response {
      case .success(let code, _, _):
        VGSAnalyticsClient.shared.trackFormEvent(self.formAnalyticsDetails,
                                                type: .submit,
                                                status: .success,
                                                extraData: ["action": "getCardAttributes",
                                                          "statusCode": code,
                                                          "fieldName": fieldName])
      case .failure(let code, _, _, let error):
        let errorMessage = (error as NSError?)?.localizedDescription ?? ""
        VGSAnalyticsClient.shared.trackFormEvent(self.formAnalyticsDetails,
                                                type: .submit,
                                                status: .failed,
                                                extraData: ["action": "getCardAttributes",
                                                          "statusCode": code,
                                                          "error": errorMessage,
                                                          "fieldName": fieldName])
      }
      
      completion(response)
    }
  }
  
  /**
   Async/await version of `getCardAttributes`.
   
   Fetches card attributes for a card number field using the first 11 digits.
   
   - Parameters:
      - fieldName: The field name of the card number field.
   
   - Returns: `VGSResponse` containing the card attributes or error.
   
   - Throws:
      - `VGSError` with type `.invalidFieldType` if the field is not of type `.cardNumber`.
      - `VGSError` with type `.incompleteCardNumber` if the card number has fewer than 11 digits.
   
   Usage:
   ```swift
   let response = await collector.getCardAttributes(fieldName: "card_number")
   switch response {
   case .success(let code, let data, _):
     if let data = data,
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
       print("Card attributes: \(json)")
     }
   case .failure(let code, _, _, let error):
     print("Error: \(error?.localizedDescription ?? "Unknown error")")
   }
   ```
   */
  public func getCardAttributes(fieldName: String) async -> VGSResponse {
    await withCheckedContinuation { continuation in
      getCardAttributes(fieldName: fieldName) { response in
        continuation.resume(returning: response)
      }
    }
  }
}
