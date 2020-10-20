//
//  Storage.swift
//  VGSCollectSDK
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Vitalii Obertynskyi. All rights reserved.
//

import Foundation
#if os(iOS)
import UIKit
#endif

/// Class Responsible for storing elements registered with VGSCollect instance
internal class Storage {
    
    var elements = [VGSTextField]()
    var files = BodyData()
    
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
    
    func removeFiles() {
        files = BodyData()
    }
}
