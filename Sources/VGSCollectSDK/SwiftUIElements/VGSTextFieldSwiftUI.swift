//
//  VGSTextFieldSwiftUI.swift
//  VGSCollectSDK
//

import SwiftUI
import Combine

@available(iOS 14.0, *)
internal final class SecureInputStore: ObservableObject {
    @Published private(set) var secureInput: String = ""

    func updateInput(_ input: String) {
        secureInput = input
    }
}

@available(iOS 14.0, *)
public struct VGSTextFieldSwiftUI: View {
    @StateObject private var inputStore = SecureInputStore()
    @State private var input: String = ""
    @State private var isValid: Bool = true
    @State var placeholder: String = ""
    
    var configuration: VGSConfiguration

    public init(configuration: VGSConfiguration) {
        self.configuration = configuration
    }

    private func validateInput(_ input: String) -> Bool {
      return true
    }

    private func applyConfiguration() {
        // Apply the configuration settings to the VGSTextFieldSwiftUI
        // This can include setting up font, text color, placeholder, etc.
    }

    public var body: some View {
        TextField("VGSTextField", text: $input, onCommit: {
            inputStore.updateInput(input)
            isValid = validateInput(input)
        })
//        .padding()
//        .textFieldStyle(RoundedBorderTextFieldStyle())
//        .background(isValid ? Color.clear : Color.red.opacity(0.2))
        .onChange(of: input) { newValue in
            inputStore.updateInput(newValue)
            isValid = validateInput(newValue)
        }
        .onAppear(perform: applyConfiguration)
    }
}

@available(iOS 14.0, *)
struct VGSTextFieldSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
      let collector = VGSCollect(id: "test", environment: "sandbox")
      let configuration = VGSConfiguration(collector: collector, fieldName: "")
        return VGSTextFieldSwiftUI(configuration: configuration)
    }
}
