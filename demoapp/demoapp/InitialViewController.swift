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
      textField.text = AppCollectorConfiguration.shared.vaultId
    }
        
    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
    alert.addAction(UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
      let vaultId = alert.textFields?.first?.text ?? "vaultId"
      AppCollectorConfiguration.shared.vaultId = vaultId
    }))
    self.present(alert, animated: true, completion: nil)
  }
}
