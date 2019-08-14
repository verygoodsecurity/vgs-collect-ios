//
//  VGSView.swift
//  Pods-demoapp
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//

import UIKit

public class VGSView: UIView {
    
    public var elementType: FieldsType = .nameHolderField
    
    public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    public var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Storage.shared.addElement(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Storage.shared.addElement(self)
    }
    
    deinit {
        Storage.shared.removeElement(self)
    }
}
