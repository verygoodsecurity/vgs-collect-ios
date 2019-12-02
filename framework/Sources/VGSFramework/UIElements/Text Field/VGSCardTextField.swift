//
//  VGSCardTextField.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 24.11.2019.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit

public class VGSCardTextField: VGSTextField {
    
    /// card brand icon width
    var iconWidth: CGFloat = 0
    
    /// callback for taking card brand icon
    public var cardsIconSource: ((SwiftLuhn.CardType) -> UIImage?)?
    
    lazy var cardIconView = UIImageView(frame: .zero)
    
    // MARK: - init
    override func mainInitialization() {
        super.mainInitialization()
        iconWidth = 45
        
        makeCardIcon()
        
        updateUI = { [weak self] in
            if let state = self?.state as? CardState {
                
                if self?.cardsIconSource != nil {
                    let icon = self?.cardsIconSource?(state.cardBrand)
                    self?.cardIconView.image = icon
                    
                } else {
                    self?.cardIconView.image = state.cardBrand.brandIcon
                }
            }
        }
    }
    
    private func makeCardIcon() {
        
        cardIconView.contentMode = .scaleAspectFit
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
