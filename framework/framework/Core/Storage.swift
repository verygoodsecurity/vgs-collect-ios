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
    
    private var elements = [VGSTextField]()
    
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
    
    func sendData(completion block:@escaping (_ data: JsonData?, _ error: Error?) -> Void) {
        
        var body = BodyData()
        
        let allKeys = elements.compactMap( { $0.model?.alias } )
        allKeys.forEach { key in
            if let value = elements.filter( { $0.model?.alias == key } ).first {
                body[key] = value.text
            } else {
                fatalError("Wrong key: \(key)")
            }
        }
        
        APIClient.sendSaveCardRequest(value: body) { [weak self] (json, error) in
            
            if let error = error {
                print("Error: \(String(describing: error.localizedDescription))")
                block(json, error)
                
            } else {
                let allKeys = json?.keys
                allKeys?.forEach({ key in
                    
                    if let element = self?.elements.filter( { $0.model?.alias == key } ).first {
                        element.model?.token = json?[key] as? String
                    }
                })
            }
            
            print(">>> \(String(describing: self?.elements.compactMap( { $0.model?.token } )))")
            
            block(json, nil)
        }
    }
}
