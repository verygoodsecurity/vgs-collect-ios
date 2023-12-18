//
//  PlaidDataCollectingViewController.swift
//  demoapp
//

import UIKit
import VGSCollectSDK

class PlaidDataCollectingViewController: UIViewController {
  
  @IBOutlet weak var consoleStatusLabel: UILabel!
  @IBOutlet weak var consoleLabel: UILabel!
  
  // Init VGS Collector
  var vgsCollect = VGSCollect(id: AppCollectorConfiguration.shared.vaultId, environment: AppCollectorConfiguration.shared.environment)
  
  // VGSPlaid LinkKit handler
  var linkHandler: VGSPlaidLinkHandler?
  
  // Start Plaid flow
  @IBAction func openPlaid(_ sender: Any) {
      
    self.linkHandler = VGSPlaidLinkHandler(collector: vgsCollect, linkToken: "link-sandbox-b081e669-a760-4e3a-84df-d2aebcee4b1e", delegate: self)
    self.linkHandler?.open(on: self)
  }
}

extension PlaidDataCollectingViewController: VGSPlaidLinkHandlerDelegate {
  func didFinish(with metadata: [String : Any]) {
    let response = (String(data: try! JSONSerialization.data(withJSONObject: metadata, options: .prettyPrinted), encoding: .utf8)!)
    self.consoleLabel.text = response
  }
}
