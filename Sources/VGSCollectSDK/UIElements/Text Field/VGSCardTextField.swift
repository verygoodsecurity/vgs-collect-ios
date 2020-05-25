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
        case left(size: CGSize)
        case right(size: CGSize)
    }
    
    internal var originalLeftPadding: CGFloat = -1
    internal var originalRightPadding: CGFloat = -1
    
    /// card brand icon width
    internal var iconSize: CGSize = .zero
    
    /// callback for taking card brand icon
    public var cardsIconSource: ((SwiftLuhn.CardType) -> UIImage?)?
    
    /// set side icon near text view. The right by default.
    public var sideCardIcon: SideCardIcon = .right(size: .zero) {
        didSet {
            switch sideCardIcon {
            case .left(let size):
                iconSize = size
                
                textField.rightView = nil
                textField.leftView = cardIconView
                textField.leftViewMode = .always
                
                // save original left padding
                if originalLeftPadding < 0 {
                    originalLeftPadding = padding.left
                }
                var paddingCopy = padding
                // set left padding
                paddingCopy.left = originalLeftPadding + size.width
                // reset right padding
                if originalRightPadding > 0 {
                    paddingCopy.right = originalRightPadding
                    originalRightPadding = -1
                }
                // set new padding value
                padding = paddingCopy
                
            case .right(let size):
                iconSize = size
                
                textField.leftView = nil
                textField.rightView = cardIconView
                textField.rightViewMode = .always
                
                // save original right padding
                if originalRightPadding < 0 {
                    originalRightPadding = padding.right
                }
                var paddingCopy = padding
                // set right padding
                paddingCopy.right = originalRightPadding + size.width
                // reset left padding
                if originalLeftPadding > 0 {
                    paddingCopy.left = originalLeftPadding
                    originalLeftPadding = -1
                }
                // set new padding value
                padding = paddingCopy
            }
            updateCardIcon()
        }
    }
    
    internal lazy var cardIconView = self.makeCardIcon()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textField.semanticContentAttribute = .forceLeftToRight
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        textField.semanticContentAttribute = .forceLeftToRight
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateCardIcon()
    }
    
    // override textFieldDidChange
    override func textFieldValueChanged() {
        super.textFieldValueChanged()
        updateCardIcon()
    }
    
    private func updateImageViewSize() {
        if let widthConstraint = cardIconView.constraints.filter({ $0.identifier == "widthConstraint" }).first {
            widthConstraint.constant = iconSize.width
        }
        if let heightConstraint = cardIconView.constraints.filter({ $0.identifier == "heightConstraint" }).first {
            heightConstraint.constant = iconSize.height
        }
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
            updateImageViewSize()
            cardIconView.image = ico//.resizeImage(icon: iconSize)
        } else {
            cardIconView.image = nil
        }
    }
    
    // make image view for a card brand icon
    private func makeCardIcon() -> UIImageView {
        let result = UIImageView(frame: .zero)
        result.contentMode = .scaleAspectFit        
        let newView = result
        newView.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = NSLayoutConstraint(item: newView,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: iconSize.width)
        widthConstraint.identifier = "widthConstraint"
        let heightConstraint = NSLayoutConstraint(item: newView,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: iconSize.height)
        heightConstraint.identifier = "heightConstraint"
        newView.addConstraints([widthConstraint, heightConstraint])
        return newView
    }
}
