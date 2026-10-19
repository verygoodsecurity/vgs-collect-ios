//
//  InitialViewController.swift
//  demoapp
//
//  Created by Dima on 29.07.2020.
//  Copyright © 2020 Very Good Security. All rights reserved.
//

import Foundation
import UIKit

class InitialViewController: UITableViewController {
  
  @IBAction func setupVaultIdAction(_ sender: Any) {
    
    let alert = UIAlertController(title: "Set <tenant ID>", message: "Enter your tenant ID.", preferredStyle: UIAlertController.Style.alert)
    alert.addTextField { (textField) in
      textField.clearButtonMode = .always
      textField.text = AppCollectorConfiguration.shared.tenantId
    }
        
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
    alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { (_)in
      let tenantId = alert.textFields?.first?.text ?? "tenantId"
      AppCollectorConfiguration.shared.tenantId = tenantId
    }))

		if let popoverController = alert.popoverPresentationController {
			popoverController.sourceView = self.view // to set the source of your alert
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
			popoverController.permittedArrowDirections = [] // to hide the arrow of any particular direction
		}

    self.present(alert, animated: true, completion: nil)
  }

	override func viewDidLoad() {
		super.viewDidLoad()

		// Setup data for UITests only.
		UITestsMockedDataProvider.setupMockedDataForTestsIfNeeded()
	}
}
