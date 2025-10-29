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
///
/// Overview:
/// `VGSCardTextField` extends `VGSTextField` to provide real-time card brand detection (Visa, Mastercard, etc.) and an optional brand icon. It dynamically:
/// - Detects card brand as the user types.
/// - Updates spacing/formatting pattern automatically.
/// - Propagates brand-specific CVC length & formatting to attached `VGSCVCTextField`.
///
/// Usage:
/// 1. Create instance and assign a `VGSConfiguration` whose `type` is `.cardNumber` (or specialized tokenization configuration).
/// 2. Optionally customize icon presentation via `cardIconLocation`, `cardIconSize`, or supply a closure in `cardsIconSource` for custom imagery.
/// 3. Observe field state (`state` cast to `VGSCardState`) to access `bin`, `last4`, and `cardBrand` after valid input.
///
/// Accessibility:
/// - Keep `cardIconViewIsAccessibilityElement = true` for voiceover users; set `cardIconAccessibilityHint` to a localized brand description.
/// - Avoid adding sensitive PAN information to accessibility hints.
///
/// Performance:
/// Brand detection runs on each input change.
///
/// Security:
/// - No raw PAN characters are logged or exposed via public API.
public final class VGSCardTextField: VGSTextField {
  
  internal let cardIconView = UIImageView()
  internal lazy var stackView = self.makeStackView()
  internal let stackSpacing: CGFloat = 8.0
  internal lazy var defaultUnknowBrandImage: UIImage? = {
    return VGSPaymentCards.CardBrand.unknown.brandIcon
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
  
  /// Card brand icon size. Adjust before heavy layout cycles; changing will update size constraints.
  public var cardIconSize: CGSize = CGSize(width: 45, height: 45) {
    didSet {
      updateCardIconViewSize()
    }
  }
    
  /// Card Icon accessibility element flag. Set `false` to hide icon from VoiceOver if redundant.
  public var cardIconViewIsAccessibilityElement = true {
        didSet {
            cardIconView.isAccessibilityElement = cardIconViewIsAccessibilityElement
        }
    }
    
  /// Card Icon accessibility hint. Provide a localized description of current brand (e.g. "Visa card brand icon").
  public var  cardIconAccessibilityHint = "card brand icon"

  // MARK: Custom card brand images
  /// Custom card brand image provider. Return a `UIImage` for the detected brand or `nil` to fallback to default asset.
  public var cardsIconSource: ((VGSPaymentCards.CardBrand) -> UIImage?)?

  /// :nodoc: (Internal lifecycle) Ensures icon updates when view is attached.
  public override func didMoveToSuperview() {
    super.didMoveToSuperview()
    updateCardImage()
  }
  
  /// The natural size for the Textfield, considering only properties of the view itself plus icon width & height.
  public override var intrinsicContentSize: CGSize {
    return getIntrinsicContentSize()
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
  
    /// Calculate IntrinsicContentSize
    private func getIntrinsicContentSize() -> CGSize {
      // Text size with paddings
      let size = super.intrinsicContentSize
      // Add icon size
      let height = size.height + cardIconSize.height
      let width = size.width + cardIconSize.width + stackSpacing
      return CGSize(width: width, height: height)
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
  
    /// Update card brand icon based on detected brand (or unknown fallback) and refresh accessibility hint.
    func updateCardImage() {
       if let state = state as? VGSCardState {
          cardIconView.image = (cardsIconSource == nil) ? state.cardBrand.brandIcon :  cardsIconSource?(state.cardBrand)
       } else {
        cardIconView.image = VGSPaymentCards.unknown.brandIcon
       }
        /// Update accessibility hint
        cardIconView.accessibilityHint = cardIconAccessibilityHint
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
