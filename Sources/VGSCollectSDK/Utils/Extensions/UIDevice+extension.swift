//
//  UIDevice+extension.swift
//  VGSCollectSDK
//
//  Created by Dima on 24.11.2020.
//  Copyright © 2020 VGS. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

internal extension UIDevice {
  
  // device model identifier, like iPhone 3,1(not marketing iPhone model)
  var modelIdentifier: String {
    if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
    var sysinfo = utsname()
    uname(&sysinfo) // ignore return value
    return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? "unknown"
    }
  }
