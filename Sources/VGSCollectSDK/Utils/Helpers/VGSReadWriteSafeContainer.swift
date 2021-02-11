//
//  VGSReadWriteSafeContainer.swift
//  VGSCollectSDK
//

import Foundation

/// Thread safe read-write container.
internal class VGSReadWriteSafeContainer {

	  /// Concurrent queue to schedule tasks.
	 	internal let concurentQueue: DispatchQueue

	/// Initialization.
	/// - Parameter label: `String` object, should be unique queue identifier.
		init(label: String) {
				concurentQueue = DispatchQueue(label: label, qos: .utility, attributes: .concurrent)
		}

	/// Execute closure to read some data.
	/// - Parameter closure: `() -> ()` closure.
		func read(closure: () -> Void) {
				concurentQueue.sync {
						closure()
				}
		}

	/// Execute closure to write some data in thead-safe way.
	/// - Parameter closure: `() -> ()` closure.
		func write(closure: () -> Void) {
				concurentQueue.sync(flags: .barrier, execute: {
						closure()
				})
		}
}
