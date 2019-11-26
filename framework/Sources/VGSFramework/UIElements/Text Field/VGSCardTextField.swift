//
//  VGSCardTextField.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 24.11.2019.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit

public class VGSCardTextField: VGSTextField {
    
    private var iconWidth: CGFloat = 45
    
    lazy var leftView = UIImageView(frame: .zero)
    
    override func mainInitialization() {
        super.mainInitialization()
        
        leftView.contentMode = .scaleAspectFit
        textField.leftView = leftView
        
        // width constraint
        let views = ["view": self, "leftView": leftView]
        leftView.translatesAutoresizingMaskIntoConstraints = false
        let width = NSLayoutConstraint.constraints(withVisualFormat: "H:[leftView(==\(iconWidth))]",
            options: .alignAllLeading,
                                                   metrics: nil,
                                                   views: views)
        
        NSLayoutConstraint.activate(width)
        
        padding.left += iconWidth + 5
        
        updateUI = { [weak self] in
            let state = self?.state as! CardState
            self?.updateCardIcon(with: state)
        }
    }
    
    private func updateCardIcon(with state: CardState) {
        guard let bundleURL = Bundle(for: type(of: self)).url(forResource: "CardIcon", withExtension: "bundle"), let bundle = Bundle(url: bundleURL) else {
            return
        }
        
        var icon: UIImage!
        
        switch state.cardBrand {
        case .visa:
            icon = UIImage(named: "1", in: bundle, compatibleWith: nil)
        default:
            icon = nil
        }

        leftView.image = icon
    }
}
