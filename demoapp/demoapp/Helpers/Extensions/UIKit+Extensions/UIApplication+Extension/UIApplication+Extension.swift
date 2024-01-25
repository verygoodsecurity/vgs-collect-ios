//
//  UIApplication+Extension.swift
//  demoapp
//

import UIKit

extension UIApplication {
    /// Resign first responder. NOTE: Used in SwiftUI views.
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
