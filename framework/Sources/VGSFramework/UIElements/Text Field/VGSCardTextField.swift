//
//  VGSCardTextField.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 24.11.2019.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit

public class VGSCardTextField: VGSTextField {
    
    public var iconWidth: CGFloat = 45 {
        didSet {
            // width constraint
            let views = ["view": self, "leftView": leftView]
            leftView.translatesAutoresizingMaskIntoConstraints = false
            
            let width = NSLayoutConstraint.constraints(withVisualFormat: "H:[leftView(==\(iconWidth))]", options: .alignAllCenterX, metrics: nil, views: views)
            NSLayoutConstraint.activate(width)
            padding.left += iconWidth + 5
        }
    }
    
    lazy var leftView = UIImageView(frame: .zero)
    
    // MARK: - init
    override func mainInitialization() {
        super.mainInitialization()
        
        leftView.contentMode = .scaleAspectFit
        textField.leftView = leftView

        updateUI = { [weak self] in
            if let state = self?.state as? CardState {
                self?.leftView.image = state.cardBrand.brandIcon
            }
        }
    }
}
