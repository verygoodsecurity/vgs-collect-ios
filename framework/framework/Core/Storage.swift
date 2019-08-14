//
//  Storage.swift
//  framework
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

class Storage {
    
    static var shared = Storage()
    
    private var elements = [VGSView]()
    
    func addElement(_ element: VGSView) {
        if elements.filter({ $0 == element }).count == 0 {
            elements.append(element)
        }
    }
    
    func removeElement(_ element: VGSView) {
        if let index = elements.firstIndex(of: element) {
            elements.remove(at: index)
        }
    }
}
