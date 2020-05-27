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
    
    /// card brand icon width
    internal var iconSize: CGSize = .zero {
        didSet {
            updateImageViewSize()
        }
    }
    
    /// callback for taking card brand icon
    public var cardsIconSource: ((SwiftLuhn.CardType) -> UIImage?)?
    
    /// set side icon near text view. The right by default.
    public var sideCardIcon: SideCardIcon = .right(size: CGSize(width: 42, height: 42)) {
        didSet {
            cardIconView.removeFromSuperview()
            
            switch sideCardIcon {
            case .left(let size):
                iconSize = size
                stackView.insertArrangedSubview(cardIconView, at: 0)
                
            case .right(let size):
                iconSize = size
                stackView.addArrangedSubview(cardIconView)
            }
            updateCardIcon()
        }
    }
    
    internal lazy var cardIconView = self.makeCardIcon()
    internal lazy var stackView = self.makeStackView()
    
    // MARK: - Initialization
    override func mainInitialization() {
        // set main style for view
        mainStyle()
        // stack view
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["view": self, "stackView": stackView]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(8)-[stackView]-(8)-|",
                                                                   options: .alignAllCenterY,
                                                                   metrics: nil,
                                                                   views: views)
        NSLayoutConstraint.activate(horizontalConstraints)
        
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|",
                                                                options: .alignAllCenterX,
                                                                metrics: nil,
                                                                views: views)
        NSLayoutConstraint.activate(verticalConstraint)
        
        // text field
        textField.translatesAutoresizingMaskIntoConstraints = true
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 9.0
        stackView.addArrangedSubview(textField)
        
        //delegates
        //Note: .allEditingEvents doesn't work proparly when set text programatically. Use setText instead!
        textField.addSomeTarget(self, action: #selector(textFieldValueChanged), for: .allEditingEvents)
        textField.addSomeTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
        textField.addSomeTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
        textField.addSomeTarget(self, action: #selector(textFieldDidEndEditingOnExit), for: .editingDidEndOnExit)
        // tap gesture for update focus state
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusOn))
        textField.addGestureRecognizer(tapGesture)
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
            cardIconView.image = ico
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
    
    private func makeStackView() -> UIStackView {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }
}
