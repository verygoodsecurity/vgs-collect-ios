//
//  VGSTextFieldRepresentableCoordinator.swift
//  VGSCollectSDK
//
import SwiftUI

/// :nodoc: Base Class responsinble for handling VGSTextFieldRepresentable editing events and state changes
public class VGSTextFieldRepresentableCoordinator<Parent: VGSTextFieldRepresentableCallbacksProtocol>: NSObject, VGSTextFieldDelegate {
    var parent: Parent

    init(_ parent: Parent) {
        self.parent = parent
    }
    /// `VGSTextFieldRepresentable` did become first responder.
    @MainActor
    public func vgsTextFieldDidBeginEditing(_ textField: VGSTextField) {
        if let state = textField.state as? Parent.StateType {
          self.parent.onEditingEvent?(.didBegin(state: state))
          self.parent.onStateChange?(state)
      }
    }
    /// `VGSTextFieldRepresentable` input changed.
    @MainActor
    public func vgsTextFieldDidChange(_ textField: VGSTextField) {
        if let state = textField.state as? Parent.StateType {
          self.parent.onEditingEvent?(.didChange(state: state))
          self.parent.onStateChange?(state)
      }
    }
    /// `VGSTextFieldRepresentable`did resign first responder.
    @MainActor
    public func vgsTextFieldDidEndEditing(_ textField: VGSTextField) {
        if let state = textField.state as? Parent.StateType {
          self.parent.onEditingEvent?(.didEnd(state: state))
          self.parent.onStateChange?(state)
      }
    }
    /// `VGSTextFieldRepresentable`did resign first responder  on Return button pressed..
    @MainActor
    public func vgsTextFieldDidEndEditingOnReturn(_ textField: VGSTextField) {
        if let state = textField.state as? Parent.StateType {
          self.parent.onEditingEvent?(.didEnd(state: state))
          self.parent.onStateChange?(state)
      }
    }
}
