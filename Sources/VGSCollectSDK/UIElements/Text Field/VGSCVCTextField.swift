//
//  VGSCVCTextField.swift
//  VGSCollectSDK
//
//  Created by Dima on 16.02.2021.
//  Copyright © 2021 VGS. All rights reserved.
//

#if os(iOS)
import UIKit
#endif

/// An object that displays an editable text area. Can be use instead of a `VGSTextField` when need to show CVC/CVV images for credit card brands.
public final class VGSCVCTextField: VGSTextField {
  
    internal let cvcIconView = UIImageView()
    internal lazy var stackView = self.makeStackView()
    internal let stackSpacing: CGFloat = 8.0
  
    // MARK: - Enum cases
    /// Available CVC icon positions enum.
    public enum CVCIconLocation {
        /// CVC icon at left side of `VGSCardTextField`.
        case left
      
        /// CVC icon at right side of `VGSCardTextField`.
        case right
    }
    
    // MARK: Attributes
    /// CVC icon position inside `VGSCardTextField`.
    public var cvcIconLocation = CVCIconLocation.right {
      didSet {
        setCVCIconAtLocation(cvcIconLocation)
      }
    }
  
    /// CVC icon size.
    public var cvcIconSize: CGSize = CGSize(width: 45, height: 45) {
        didSet {
            updatecvcIconViewSize()
        }
    }
    
    // MARK: Custom CVC images for specific card brands
    /// Asks custom image for specific `VGSPaymentCards.CardBrand`
    public var cvcIconSource: ((VGSPaymentCards.CardBrand) -> UIImage?)?
    
    /// :nodoc:
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateCVCImage(for: .unknown)
    }
}

internal extension VGSCVCTextField {
  
    // MARK: - Initialization
    override func mainInitialization() {
        super.mainInitialization()
        
        setupCVCIconView()
        setCVCIconAtLocation(cvcIconLocation)
        updateCVCImage(for: .unknown)
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

  
    func updateCVCImage(for cardBrand: VGSPaymentCards.CardBrand) {
        cvcIconView.image = (cvcIconSource == nil) ? cardBrand.cvcIcon :  cvcIconSource?(cardBrand)
    }
  
    func setCVCIconAtLocation(_ location: CVCIconLocation) {
        cvcIconView.removeFromSuperview()
        switch location {
        case .left:
            stackView.insertArrangedSubview(cvcIconView, at: 0)
        case .right:
            stackView.addArrangedSubview(cvcIconView)
        }
    }
    
    func updatecvcIconViewSize() {
        if let widthConstraint = cvcIconView.constraints.filter({ $0.identifier == "widthConstraint" }).first {
            widthConstraint.constant = cvcIconSize.width
        }
        if let heightConstraint = cvcIconView.constraints.filter({ $0.identifier == "heightConstraint" }).first {
            heightConstraint.constant = cvcIconSize.height
        }
    }
    
    // Make image view for a card brand icon
    private func setupCVCIconView() {
        cvcIconView.translatesAutoresizingMaskIntoConstraints = false
        cvcIconView.contentMode = .scaleAspectFit
        let widthConstraint = NSLayoutConstraint(item: cvcIconView,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1,
                                                 constant: cvcIconSize.width)
        widthConstraint.identifier = "widthConstraint"
        let heightConstraint = NSLayoutConstraint(item: cvcIconView,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1,
                                                  constant: cvcIconSize.height)
        heightConstraint.identifier = "heightConstraint"
        // fix conflict with textfield height constraint when card icon more higher then textfield
        heightConstraint.priority = UILayoutPriority(rawValue: 999)
        cvcIconView.addConstraints([widthConstraint, heightConstraint])
    }
}
