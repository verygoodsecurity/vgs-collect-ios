//
//  UIImage+resize.swift
//  VGSFramework
//
//  Created by Vitalii Obertynskyi on 20.04.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation

internal extension UIImage {
    func resizeImage(width: CGFloat) -> UIImage? {
        let scale = width / size.width
        let newHeight = size.height * scale
       
        UIGraphicsBeginImageContext(CGSize(width: width, height: newHeight))
        draw(in: CGRect(x: 0, y: 0, width: width, height: newHeight))
       
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
