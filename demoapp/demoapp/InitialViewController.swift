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
    
    let alert = UIAlertController(title: "Set <vault id>", message: "Add your organization valut id here", preferredStyle: UIAlertController.Style.alert)
    alert.addTextField { (textField) in
      textField.clearButtonMode = .always
      textField.text = AppCollectorConfiguration.shared.vaultId
    }
        
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
    alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { (_)in
      let vaultId = alert.textFields?.first?.text ?? "vaultId"
      AppCollectorConfiguration.shared.vaultId = vaultId
    }))

		if let popoverController = self.popoverPresentationController {
			popoverController.sourceView = self.view //to set the source of your alert
			popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
			popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
		}

    self.present(alert, animated: true, completion: nil)
  }
}
