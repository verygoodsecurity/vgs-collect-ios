//
//  VGSView.swift
//  Pods-demoapp
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//

import UIKit

public class VGSView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        mainStyle()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mainStyle()
    }
}

// MARK: - Setting main UI pattern
extension VGSView {
    private func mainStyle() {
        clipsToBounds = true
        
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4
    }
}
