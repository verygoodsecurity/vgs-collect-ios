//
//  VGSTextFieldRepresentableCoordinator.swift
//  VGSCollectSDK
//
import SwiftUI

/// Base Class responsinble for handling VGSTextFieldRepresentable editing events and state changes
public class VGSTextFieldRepresentableCoordinator<Parent: VGSTextFieldRepresentableCallbacksProtocol>: NSObject, VGSTextFieldDelegate {
    var parent: Parent

    init(_ parent: Parent) {
        self.parent = parent
    }
    /// `VGSTextFieldRepresentable` did become first responder.
    public func vgsTextFieldDidBeginEditing(_ textField: VGSTextField) {
        if let state = textField.state as? Parent.StateType {
          parent.onEditingEvent?(.didBegin(state: state))
          parent.onStateChange?(state)
        }
    }
    /// `VGSTextFieldRepresentable` input changed.
    public func vgsTextFieldDidChange(_ textField: VGSTextField) {
        if let state = textField.state as? Parent.StateType {
          parent.onEditingEvent?(.didChange(state: state))
          parent.onStateChange?(state)
        }
    }
    /// `VGSTextFieldRepresentable`did resign first responder.
    public func vgsTextFieldDidEndEditing(_ textField: VGSTextField) {
        if let state = textField.state as? Parent.StateType {
          parent.onEditingEvent?(.didEnd(state: state))
          parent.onStateChange?(state)
        }
    }
    /// `VGSTextFieldRepresentable`did resign first responder  on Return button pressed..
    public func vgsTextFieldDidEndEditingOnReturn(_ textField: VGSTextField) {
        if let state = textField.state as? Parent.StateType {
          parent.onEditingEvent?(.didEnd(state: state))
          parent.onStateChange?(state)
        }
    }
}
