//
//  XCUITestCase+Extensions.swift
//  demoappUITests

import Foundation
import XCTest

extension XCTestCase {
	func wait(forTimeInterval: TimeInterval) {
		Thread.sleep(forTimeInterval: forTimeInterval)
	}
}
