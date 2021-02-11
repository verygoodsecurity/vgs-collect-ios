//
//  AppDelegate.swift
//  demoapp
//
//  Created by Vitalii Obertynskyi on 8/14/19.
//  Copyright © 2019 Very Good Security. All rights reserved.
//

import UIKit
import VGSCollectSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

				 // Don't use VGSCollectLogger in live apps, double-check your own configuration setup when using debugging options!
			   #if DEBUG
				   // Log only warnings and errors.
				   VGSCollectLogger.shared.configuration.level = .warning

				  // Log network requests.
				  VGSCollectLogger.shared.configuration.isNetworkDebugEnabled = true
				#endif

			  // *You can stop all loggers in app with:
			  // VGSCollectLogger.shared.disableAllLoggers()

        return true
    }
}
