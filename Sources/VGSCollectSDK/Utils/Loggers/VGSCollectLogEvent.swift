//
//  VGSLogEvent.swift
//  VGSCollectSDK
//

import Foundation

/// Holds logging data.
internal struct VGSLogEvent {

	/// Severity level of event.
	internal enum SeverityLevel {

		/// Warning, indicates problem in normal flow but not critical.
		case warning

		/// Error, indicates error.
		case error

		/// Text for debug output.
		var debugText: String {
			switch self {
			case .warning:
				return "⚠️"
			case .error:
				return "❌"
			}
		}
	}

	/// Log level.
	internal let level: VGSLogLevel

	/// Text to log.
	internal let text: String

	/// Filename of calling function.
	internal let file: String

	/// Function where log event is triggered.
	internal let functionName: String

	/// Line number of calling function where event is triggered.
	internal let lineNumber: Int

	/// Severity level.
	internal let severityLevel: SeverityLevel?

	/// Initializer.
	/// - Parameters:
	///   - level: `VGSLogLevel` object, log level.
	///   - text: `String` object, raw text to log.
	///   - severityLevel: `SeverityLevel?` object, should be used to indicate errors or warnings. Default is `nil`.
	///   - file: `String` object, refers to filename of calling function.
	///   - functionName: `String` object, refers to filename of calling function.
	///   - lineNumber: `Int` object, refers to line number of calling function.
	internal init(level: VGSLogLevel, text: String, severityLevel: SeverityLevel? = nil, file: String = #file, functionName: String = #function, lineNumber: Int = #line) {
		self.text = text
		self.severityLevel = severityLevel
		self.level = level
		self.functionName = functionName
		self.lineNumber = lineNumber
		if let outputFile = file.components(separatedBy: "/").last {
				self.file = outputFile
		} else {
				self.file = file
		}
	}

	/// Convert log event to debug string.
	/// - Parameter isExtensiveDebugEnabled: `Bool` flag, specify `true` to set extensive format.
	/// - Returns: `String` object, formatted log event.
	internal func convertToDebugString(isExtensiveDebugEnabled: Bool) -> String {
		var severityText = ""
		if let severity = severityLevel?.debugText {
			severityText = severity
		}
		if isExtensiveDebugEnabled {
			return "[VGSCollectSDK - \(severityText) \(text) - logLevel: \(level) - file: \(file) - func: \(functionName) - line: \(lineNumber)]"
		} else {
			return "[VGSCollectSDK - \(severityText) \(text) - logLevel: \(level)]"
		}
	}
}

/// Interface for event logging.
internal protocol VGSLogging {
	func logEvent(_ event: VGSLogEvent, isExtensiveDebugEnabled: Bool)
}
