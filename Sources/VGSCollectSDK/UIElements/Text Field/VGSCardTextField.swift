//
//  VGSCardTextField.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 24.11.2019.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

#if os(iOS)
import UIKit
#endif

/// An object that displays an editable text area. Can be use instead of a `VGSTextField` when need to detect and show credit card brand images.
public final class VGSCardTextField: VGSTextField {
  
    internal let cardIconView = UIImageView()
    internal lazy var stackView = self.makeStackView()
    internal let stackSpacing: CGFloat = 8.0
    internal lazy var defaultUnknowBrandImage: UIImage? = {
      return UIImage(named: "unknown", in: AssetsBundle.main.iconBundle, compatibleWith: nil)
    }()
  
    // MARK: - Enum cases
    /// Available Card brand icon positions enum.
    public enum CardIconLocation {
        /// Card brand icon at left side of `VGSCardTextField`.
        case left
      
        /// Card brand icon at right side of `VGSCardTextField`.
        case right
    }
    
    // MARK: Attributes
    /// Card brand icon position inside `VGSCardTextField`.
    public var cardIconLocation = CardIconLocation.right {
      didSet {
        setCardIconAtLocation(cardIconLocation)
      }
    }
  
    /// Card brand icon size.
    public var cardIconSize: CGSize = CGSize(width: 45, height: 45) {
        didSet {
            updateCardIconViewSize()
        }
    }
    
    // MARK: Custom card brand images
    /// Asks custom image for specific `VGSPaymentCards.CardBrand`
    public var cardsIconSource: ((VGSPaymentCards.CardBrand) -> UIImage?)?
    
    /// :nodoc:
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateCardImage()
    }
}

internal extension VGSCardTextField {
  
    // MARK: - Initialization
    override func mainInitialization() {
        super.mainInitialization()
        
        setupCardIconView()
        setCardIconAtLocation(cardIconLocation)
        updateCardImage()
    }
  
    override func buildTextFieldUI() {
        addSubview(stackView)
        textField.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(textField)
        setMainPaddings()
    }
    
    override func setMainPaddings() {
      NSLayoutConstraint.deactivate(verticalConstraint)
      NSLayoutConstraint.deactivate(horizontalConstraints)
      
      let views = ["view": self, "stackView": stackView]
      
      horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(padding.left)-[stackView]-\(padding.right)-|",
                                                                 options: .alignAllCenterY,
                                                                 metrics: nil,
                                                                 views: views)
      NSLayoutConstraint.activate(horizontalConstraints)
      
      verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(padding.top)-[stackView]-\(padding.bottom)-|",
                                                              options: .alignAllCenterX,
                                                              metrics: nil,
                                                              views: views)
      NSLayoutConstraint.activate(verticalConstraint)
      self.layoutIfNeeded()
    }
  
    private func makeStackView() -> UIStackView {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        return stack
    }
  
    // override textFieldDidChange
    override func textFieldValueChanged() {
        super.textFieldValueChanged()
        updateCardImage()
    }
  
    func updateCardImage() {
       if let state = state as? CardState {
          cardIconView.image = (cardsIconSource == nil) ? state.cardBrand.brandIcon :  cardsIconSource?(state.cardBrand)
       } else {
        cardIconView.image = VGSPaymentCards.unknown.brandIcon
       }
    }
  
    func setCardIconAtLocation(_ location: CardIconLocation) {
        cardIconView.removeFromSuperview()
        switch location {
        case .left:
            stackView.insertArrangedSubview(cardIconView, at: 0)
        case .right:
            stackView.addArrangedSubview(cardIconView)
        }
    }
    
    func updateCardIconViewSize() {
        if let widthConstraint = cardIconView.constraints.filter({ $0.identifier == "widthConstraint" }).first {
            widthConstraint.constant = cardIconSize.width
        }
        if let heightConstraint = cardIconView.constraints.filter({ $0.identifier == "heightConstraint" }).first {
            heightConstraint.constant = cardIconSize.height
        }
    }
    
    // make image view for a card brand icon
    private func setupCardIconView() {
        cardIconView.translatesAutoresizingMaskIntoConstraints = false
        cardIconView.contentMode = .scaleAspectFit
        let widthConstraint = NSLayoutConstraint(item: cardIconView,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: cardIconSize.width)
        widthConstraint.identifier = "widthConstraint"
        let heightConstraint = NSLayoutConstraint(item: cardIconView,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: cardIconSize.height)
        heightConstraint.identifier = "heightConstraint"
        // fix conflict with textfield height constraint when card icon more higher then textfield
        heightConstraint.priority = UILayoutPriority(rawValue: 999)
        cardIconView.addConstraints([widthConstraint, heightConstraint])
    }
}
