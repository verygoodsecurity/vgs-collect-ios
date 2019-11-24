//
//  VGSCardTextField.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 24.11.2019.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit

public class VGSCardTextField: UIView {
    internal let stackView = UIStackView(frame: .zero)
    internal var leftView = UIImageView(frame: .zero)
    internal var rightView = UIView(frame: .zero)
    internal var vgsTextField = VGSTextField(frame: .zero)
    
    public var configuration: VGSConfiguration? {
        didSet {
            guard let config = configuration else {
                return
            }
            config.type = .cardNumber
            vgsTextField.configuration = config
        }
    }
    
    // MARL: - init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        mainInitialization()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        mainInitialization()
    }
    
    // MARK: - Private method
    private func mainInitialization() {
        mainStyle()
        
        stackView.addArrangedSubview(vgsTextField)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        let views = ["view": self, "stackView": stackView]
        // align stackView from the left and right
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stackView]-0-|",
                                                                   options: .alignAllCenterY,
                                                                   metrics: nil,
                                                                   views: views)
        NSLayoutConstraint.activate(horizontalConstraints)
        
        // align stackView from the top and bottom
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|",
                                                                options: .alignAllCenterX,
                                                                metrics: nil,
                                                                views: views)
        NSLayoutConstraint.activate(verticalConstraint)
    }
}

extension VGSCardTextField {
    public var textColor: UIColor? {
        get {
            return vgsTextField.textColor
        }
        set {
            vgsTextField.textColor = newValue
        }
    }
    
    public var font: UIFont? {
        get {
            return vgsTextField.font
        }
        set {
            vgsTextField.font = newValue
        }
    }
    
    public var padding: UIEdgeInsets {
        get {
            return vgsTextField.padding
        }
        set {
            vgsTextField.padding = newValue
        }
    }
}
