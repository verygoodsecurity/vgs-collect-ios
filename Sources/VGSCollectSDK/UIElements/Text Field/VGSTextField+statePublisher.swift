//
//  VGSTextField+statePublisher.swift
//  VGSCollectSDK
//

import Foundation
import Combine

@available(iOS 13, *)
public extension VGSTextField {
  /// `VGSTextFieldStatePublisher` publisher that emits the `State`  of a given `VGSTextField`.
    var statePublisher: VGSTextFieldStatePublisher {
        return VGSTextFieldStatePublisher(self)
    }
}

/// A custom publisher that emits `State` of a given `VGSTextField`.
@available(iOS 13, *)
public struct VGSTextFieldStatePublisher: Publisher {
  public typealias Output = VGSTextFieldState
  public typealias Failure = Never

    private unowned let vgsTextField: VGSTextField

    /// Initializer
    /// - Parameter vgsTextField: The `VGSTextField` instance to observe for state changes.
    init(_ vgsTextField: VGSTextField) {
        self.vgsTextField = vgsTextField
    }

    /// Attaches a subscriber to the publisher to receive updates on the `VGSTextField`  `State`.
    /// - Parameter subscriber: The subscriber that will receive state updates.
    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
          let subscription = VGSTextFieldStateSubscription(subscriber: subscriber, vgsTextField: vgsTextField)
          subscriber.receive(subscription: subscription)
      }
}

/// A  `VGSTextFieldStateSubscription` subscription that conforms to the `Subscription` and `VGSTextFieldDelegate` protocols.
/// Used  by the `VGSTextFieldStatePublisher` to manage the subscribers and deliver updates on the `VGSTextField`  `State`.
@available(iOS 13, *)
final class VGSTextFieldStateSubscription<S: Subscriber>: NSObject, Subscription, VGSTextFieldDelegate where S.Input == VGSTextFieldState, S.Failure == Never {
    private var subscriber: S?
    private unowned let vgsTextField: VGSTextField

    /// Initializer with a subscriber and a `VGSTextField`.
    ///
    /// - Parameters:
    ///   - subscriber: The subscriber attached to the publisher.
    ///   - vgsTextField: The `VGSTextField` instance to observe for state changes.
    init(subscriber: S, vgsTextField: VGSTextField) {
        self.subscriber = subscriber
        self.vgsTextField = vgsTextField
        super.init()
        vgsTextField.delegate = self
    }

    /// Indicates if the subscriber is ready to receive more values.
    /// - Parameter demand: The maximum number of values the subscriber is ready to receive.
    func request(_ demand: Subscribers.Demand) {
        // Nothing to do here as VGSTextFieldDelegate updates the state on demand.
    }

    /// Cancel recieve events.
    func cancel() {
        subscriber = nil
    }

    // MARK: - VGSTextFieldDelegate
  
    func vgsTextFieldDidBeginEditing(_ textField: VGSTextField) {
      _ = subscriber?.receive(textField.state)
    }

    func vgsTextFieldDidEndEditing(_ textField: VGSTextField) {
      _ = subscriber?.receive(textField.state)
    }

    func vgsTextFieldDidChange(_ textField: VGSTextField) {
      _ = subscriber?.receive(textField.state)
    }

    func vgsTextFieldDidEndEditingOnReturn(_ textField: VGSTextField) {
      _ = subscriber?.receive(textField.state)
    }
}
