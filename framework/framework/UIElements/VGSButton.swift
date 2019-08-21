//
//  VGSButton.swift
//  framework
//
//  Created by Vitalii Obertynskyi on 8/19/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import UIKit

public class VGSButton: VGSView {
    private var button = UIButton(type: .custom)
    
    public var callBack:((_ data: JsonData?, _ error: Error?) -> Void)?
    
    public var type: ButtonType = .none {
        didSet {
            if type != oldValue {
                setupButton()
            }
        }
    }
    
    public var title: String? {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }
    
    public var image: UIImage? {
        didSet {
            button.setImage(image, for: .normal)
        }
    }
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        mainInitialization()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        mainInitialization()
    }
    
    // MARK: - private API
    private func mainInitialization() {
        // add subview
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // setup UI
        button.backgroundColor = UIColor(red: 0.290, green: 0.745, blue: 0.239, alpha: 1.00)
    }
    
    private func setupButton() {
        button.setTitle(type.defaultTitle, for: .normal)
        
        // setup action
        switch type {
        case .sendButton:
            button.addTarget(self,
                             action: #selector(sendAction(_:)),
                             for: .touchUpInside)
        default:
            break
        }
    }

    // MARK: - Actions
    @objc
    private func sendAction(_ sender: UIButton) {
        
        Storage.shared.sendData { [weak self] (data, error) in
            self?.callBack?(data, error)
        }
    }
}
