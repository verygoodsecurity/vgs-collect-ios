//
//  UIImage+resize.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 20.04.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

// unused extension and excluded from target
internal extension UIImage {
    func resizeImage(icon size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
       
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
