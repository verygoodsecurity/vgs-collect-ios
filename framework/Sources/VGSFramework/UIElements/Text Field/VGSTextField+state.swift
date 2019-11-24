//
//  VGSTextField+state.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 9/10/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

public extension VGSTextField {    
    var isValid: Bool {
        let str = text ?? ""
        return validationModel.isValid(str, type: fieldType)
    }
    
    override var isFocused: Bool {
        return focusStatus
    }
    
    var state: State {
        var result: State
        
        switch fieldType {
        case .cardNumber:
            let cardState = CardState(tf: self)
//            setCradIcon(state: cardState)
            result = cardState
        default:
            result = State(tf: self)
        }
        
        return result
    }
    
    internal func setCradIcon(state: CardState) {
        var icon: UIImage?
        
        let bundleURL = Bundle(for: type(of: self)).url(forResource: "CardIcon", withExtension: "bundle")!
        let bundle = Bundle(url: bundleURL)!
        
        switch state.cardBrand {
        case .visa:
            icon = UIImage(named: "1", in: bundle, compatibleWith: nil)
            
        case .mastercard:
            icon = UIImage(named: "2", in: bundle, compatibleWith: nil)
            
        default:
            icon = nil
        }
        
        
//        let size = CGSize(width: 1, height: 10)
//        icon = UIImage.imageWithImage(image: icon, scaledToSize: size)
        
        if let leftView = textField.leftView as? UIImageView {
            leftView.image = icon
            let width = CGFloat(50)
            leftView.frame = CGRect(x: 0, y: 0, width: width, height: bounds.size.height)
            textField.padding.left = padding.left + width
            
        } else {
            let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
            imgView.contentMode = .scaleAspectFill
            imgView.clipsToBounds = true
            
            textField.leftView = imgView
            textField.leftViewMode = .always
        }
    }
}

extension UIImage {
    static func imageWithImage(image: UIImage?, scaledToSize newSize: CGSize) -> UIImage? {
        if image == nil {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image?.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
