//
//  VGSPlaidLinkHandler.swift
//  VGSPlaidLinkCollector
//
import Foundation
#if os(iOS)
import UIKit
#endif

import LinkKit
#if !COCOAPODS
import VGSCollectSDK
#endif

public protocol VGSPlaidLinkHandlerDelegate: AnyObject {
  
  func didFinish(with metadata: [String: Any])
}

/// Plaid Link SDK wrapper, manages communication between public API and Link.
@available(iOS 13.0, *)
public class VGSPlaidLinkHandler: NSObject {
  
  weak var delegate: VGSPlaidLinkHandlerDelegate?
  weak var collector: VGSCollect?
  private var handler: Handler?
  
  public required init(collector: VGSCollect, linkToken: String, delegate: VGSPlaidLinkHandlerDelegate?) {
    super.init()
    self.collector = collector
    self.delegate = delegate
    let configuration = createLinkTokenConfiguration(linkToken: linkToken)

    let result = Plaid.create(configuration)
    switch result {
    case .failure(let error):
        print("Unable to create Plaid handler due to: \(error)")
    case .success(let handler):
      self.handler = handler
    }
  }
  
  public func open(on viewController: UIViewController) {
    self.handler?.open(presentUsing: .viewController(viewController))
  }
  
  private func createLinkTokenConfiguration(linkToken: String) -> LinkTokenConfiguration {
      // In your production application replace the hardcoded linkToken above with code that fetches a linkToken
      // from your backend server which in turn retrieves it securely from Plaid, for details please refer to
      // https://plaid.com/docs/api/tokens/#linktokencreate

      var linkConfiguration = LinkTokenConfiguration(token: linkToken) { success in
          // Closure is called when a user successfully links an Item. It should take a single LinkSuccess argument,
          // containing the publicToken String and a metadata of type SuccessMetadata.
          // Ref - https://plaid.com/docs/link/ios/#onsuccess
//        print("public-token: \(success.publicToken) metadata: \(success.metadata.metadataJSON)")
        guard let metadataJSON = success.metadata.metadataJSON?.convertToDictionary() else {return}
        self.delegate?.didFinish(with: metadataJSON)
      }

      // Optional closure is called when a user exits Link without successfully linking an Item,
      // or when an error occurs during Link initialization. It should take a single LinkExit argument,
      // containing an optional error and a metadata of type ExitMetadata.
      // Ref - https://plaid.com/docs/link/ios/#onexit
      linkConfiguration.onExit = { exit in
          if let error = exit.error {
              print("exit with \(error)\n\(exit.metadata)")
          } else {
              // User exited the flow without an error.
              print("exit with \(exit.metadata)")
          }
      }

      // Optional closure is called when certain events in the Plaid Link flow have occurred, for example,
      // when the user selected an institution. This enables your application to gain further insight into
      // what is going on as the user goes through the Plaid Link flow.
      // Ref - https://plaid.com/docs/link/ios/#onevent
      linkConfiguration.onEvent = { event in
          print("Link Event: \(event)")
      }

      return linkConfiguration
  }
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }
}
