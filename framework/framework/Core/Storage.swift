//
//  Storage.swift
//  framework
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation

class Storage {
    var elements = [VGSTextField]()
    
    func addElement(_ element: VGSTextField) {
        if elements.filter({ $0 == element }).count == 0 {
            elements.append(element)
        }
    }
    
    func removeElement(_ element: VGSTextField) {
        if let index = elements.firstIndex(of: element) {
            elements.remove(at: index)
        }
    }
}
