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
        case left(width: CGFloat)
        case right(width: CGFloat)
    }
    
    internal var originalLeftPadding: CGFloat = -1
    
    /// card brand icon width
    internal var iconWidth: CGFloat = 45
    
    /// callback for taking card brand icon
    public var cardsIconSource: ((SwiftLuhn.CardType) -> UIImage?)?
    
    /// set side icon near text view. The right by default.
    public var sideCardIcon: SideCardIcon = .right(width: 45) {
        didSet {
            switch sideCardIcon {
            case .left(let width):
                iconWidth = width
                
                textField.rightView = nil
                textField.leftView = cardIconView
                textField.leftViewMode = .always
                
                if originalLeftPadding < 0 {
                    // save origibal left padding if property is < 0
                    originalLeftPadding = padding.left
                }
                
                var paddingCopy = padding
                paddingCopy.left += width
                padding = paddingCopy
                
            case .right(let width):
                iconWidth = width
                
                textField.leftView = nil
                textField.rightView = cardIconView
                textField.rightViewMode = .always
                
                if originalLeftPadding > 0 {
                    // reset left padding if property > 0
                    var paddingCopy = padding
                    paddingCopy.left = originalLeftPadding
                    padding = paddingCopy
                    originalLeftPadding = -1
                }
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
        return result
    }
}
