//
//  VGSCardTextField.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 24.11.2019.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif

/// An object that displays an editable text area. Can be use instead of a `VGSTextField` when need to detect and show credit card brand images.
public class VGSCardTextField: VGSTextField {
    public enum SideCardIcon {
        case left
        case right
    }
    
    /// card brand icon width
    public var iconWidth: CGFloat = 45 {
        didSet {
            updateCardIcon()
        }
    }
    
    /// callback for taking card brand icon
    public var cardsIconSource: ((SwiftLuhn.CardType) -> UIImage?)?
    
    /// set side icon near text view. The right by default.
    public var sideCardIcon: SideCardIcon = .right {
        didSet {
            if sideCardIcon == .left {
                textField.rightView = nil
                textField.leftView = cardIconView
                textField.leftViewMode = .always
                
                var paddingCopy = padding
                paddingCopy.left += iconWidth
                padding = paddingCopy
            } else {
                textField.leftView = nil
                textField.rightView = cardIconView
                textField.rightViewMode = .always
            }
            updateCardIcon()
        }
    }
    
    internal lazy var cardIconView = self.makeCardIcon()
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateCardIcon()
    }
    
    // override textFieldDidChange
    override func textFieldValueChanged() {
        super.textFieldValueChanged()
        updateCardIcon()
    }
    
    internal func updateCardIcon() {
        let resultIcon: UIImage?
        if let state = state as? CardState {
            if cardsIconSource != nil {
                resultIcon = cardsIconSource?(state.cardBrand)
                
            } else {
                resultIcon = state.cardBrand.brandIcon
            }
        } else {
            resultIcon = UIImage(named: "unknown", in: AssetsBundle.main.iconBundle, compatibleWith: nil)
        }
        
        if let ico = resultIcon {
            cardIconView.image = ico.resizeImage(width: iconWidth)
        } else {
            cardIconView.image = nil
        }
    }
    
    // make image view for a card brand icon
    private func makeCardIcon() -> UIImageView {
        let result = UIImageView(frame: .zero)
        
        result.contentMode = .scaleAspectFit
        addSubview(result)
        
        // make constraints
//        let views = ["view": result]
//        result.translatesAutoresizingMaskIntoConstraints = false
        
//        let width = NSLayoutConstraint.constraints(withVisualFormat: "H:[view(==\(iconWidth))]",
//                                                        options: .alignAllCenterY,
//                                                        metrics: nil,
//                                                        views: views)
//        NSLayoutConstraint.activate(width)
//
//        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|",
//                                                      options: .alignAllCenterX,
//                                                      metrics: nil,
//                                                      views: views)
//        NSLayoutConstraint.activate(vertical)
//
//        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:[view]-5-|",
//                                                        options: .alignAllCenterY,
//                                                        metrics: nil,
//                                                        views: views)
//        NSLayoutConstraint.activate(horizontal)
        
        return result
    }
}
