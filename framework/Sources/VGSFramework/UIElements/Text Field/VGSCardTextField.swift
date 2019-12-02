//
//  VGSCardTextField.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 24.11.2019.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit

public class VGSCardTextField: VGSTextField {
    
    public var iconWidth: CGFloat = 0
    
    lazy var cardIconView = UIImageView(frame: .zero)
    
    // MARK: - init
    override func mainInitialization() {
        super.mainInitialization()
        iconWidth = 45
        
        makeCardIcon()
        
        updateUI = { [weak self] in
            if let state = self?.state as? CardState {
                self?.cardIconView.image = state.cardBrand.brandIcon
            }
        }
    }
    
    private func makeCardIcon() {
        
        cardIconView.contentMode = .scaleAspectFit
//        textField.rightView = cardIconView
//        textField.rightViewMode = .always
        addSubview(cardIconView)
        
        // make constraints
        let views = ["view": cardIconView]
        cardIconView.translatesAutoresizingMaskIntoConstraints = false
        
        let width = NSLayoutConstraint.constraints(withVisualFormat: "H:[view(==\(iconWidth))]",
                                                        options: .alignAllCenterY,
                                                        metrics: nil,
                                                        views: views)
        NSLayoutConstraint.activate(width)
        
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|",
                                                      options: .alignAllCenterX,
                                                      metrics: nil,
                                                      views: views)
        NSLayoutConstraint.activate(vertical)
        
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:[view]-5-|",
                                                        options: .alignAllCenterY,
                                                        metrics: nil,
                                                        views: views)
        NSLayoutConstraint.activate(horizontal)
    }
}
