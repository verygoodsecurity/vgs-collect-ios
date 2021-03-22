//
//  VGSCollectLogger.swift
//  VGSCollectSDK
//

import Foundation

/// `VGSCollectLogger` encapsulates logging logic and debugging options for VGSCollectSDK. Use `.configuration` property to setup these options. `VGSCollectLogger` logging implies only printing logs to Xcode console. It doesn't save logs to persistent store/local file, also it doesn't send debugging logs to backend services.
/// **IMPORTANT** You should NOT use logging in your production configuration for live apps.
public final class VGSCollectLogger {

  // MARK: - vars

	/// Shared instance.
	public static var shared = VGSCollectLogger()

	/// Logging configuration. Check `VGSCollectLoggingConfiguration` for logging options.
	public var configuration: VGSCollectLoggingConfiguration = VGSCollectLoggingConfiguration()

	// MARK: - Private vars

	/// Registered loggers.
	private var registeredLoggers = [VGSLogging]()

	/// Thread safe container for registered loggers.
	private let readWriteContainer: VGSReadWriteSafeContainer = VGSReadWriteSafeContainer(label: "VGSCollectSDK.Utils.Loggers")

	// MARK: - Initialization

	/// Private init for `VGSCollectLogger`.
	private init() {
		addLogger(VGSPrintingLogger())
	}

	// MARK: - Public

	/// Stop logging *all* activities.
	public func disableAllLoggers() {
		configuration.level = .none
		configuration.isNetworkDebugEnabled = false
		configuration.isExtensiveDebugEnabled = false
	}

	// MARK: - Private

	/// Add `VGSLogging` object.
	/// - Parameter logging: `VGSLogging` object, logger.
	internal func addLogger(_ logger: VGSLogging) {
		readWriteContainer.write {
			registeredLoggers.append(logger)
		}
	}

	/// Forward event to all registered loggers.
	/// - Parameter event: `VGSLogEvent` object, event to log.
	internal func forwardLogEvent(_ event: VGSLogEvent) {
		let currentLogLevel = configuration.level
		let isExtensiveDebugEnabled = configuration.isExtensiveDebugEnabled

		// Skip forward logs if logLevel is `none`, event level should mismatch log level.
		guard currentLogLevel != .none, shouldForwardEvent(with: event.level, currentLevel: currentLogLevel) else {
			return
		}

		var loggers = [VGSLogging]()
		readWriteContainer.read {
			loggers = self.registeredLoggers
		}
		readWriteContainer.write {
			loggers.forEach {$0.logEvent(event, isExtensiveDebugEnabled: isExtensiveDebugEnabled)}
		}
	}

	/// Verify if event level should be forwarded to registered loggers.
	/// - Parameters:
	///   - level: `VGSLogLevel` object, should be event `level`.
	///   - currentLevel: `VGSLogLevel` object, current logging level.
	/// - Returns: `true` if event should be logged.
	internal func shouldForwardEvent(with level: VGSLogLevel, currentLevel: VGSLogLevel) -> Bool {
		switch currentLevel {
		case .none:
			return false
		case .info:
			/// For `.info` level forward *all* events.
			return true
		case .warning:
			/// For `.warning` level forward *only* `.warning` events.
			return level == currentLevel
		}
	}
}
