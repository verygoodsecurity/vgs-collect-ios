//
//  VGSPrintingLogger.swift
//  VGSCollectSDK
//

import Foundation

/// VGS Logger for printing log events.
internal class VGSPrintingLogger: VGSLogging {
	func logEvent(_ event: VGSLogEvent, isExtensiveDebugEnabled: Bool) {
		let messageToPrint = event.convertToDebugString(isExtensiveDebugEnabled: isExtensiveDebugEnabled)
		print(messageToPrint)
	}
}
