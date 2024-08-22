[![swiftui](https://img.shields.io/badge/SwiftUI-524520?logo=swift)]()

# SwiftUI support

VGS Collect SwiftUI wrappers are designed to make integration easier and more straight forward by taking care of all needed state and editing events.

## VGSTextFieldRepresentable
VGSTextFieldRepresentable is a SwiftUI wrapper around `VGSTextField` and have similar attributes and functionality represented in SwiftUI way. There are other field types available in SwiftUI that work same way as their UIKit versions: VGSCardTextFieldRepresentable, VGSCVCTextFieldRepresentable, VGSExpDateTextFieldRepresentable, VGSDateTextFieldRepresentable.

### Code example

```swift
struct CardDataCollectionView: View {
  // Collector
  let vgsCollect = VGSCollect(id: "vaultId" environment: .sandbox)

  // State
  @State private var textFieldState: VGSTextFieldState? = nil
  
  // MARK: - Textfield UI attributes
  let paddings = UIEdgeInsets(top: 2,left: 8,bottom: 2,right: 8)
  let validColor = UIColor.lightGray
  let invalidColor = UIColor.red
      
  // Build View
  var body: some View {
    
    // extfield Configuration
    var configuration: VGSConfiguration {
      let config = VGSConfiguration(collector: vgsCollect, fieldName: "name")
      config.type = .cardHolderName
      return config
    }
    
    return VStack() {
      VGSTextFieldRepresentable(configuration: configuration)
        .placeholder("Holder Name")
        .onEditingStart {
          print("-onEditingStart")
        }
        .onEditingEnd {
          print("-onEditingEnd")
        }
        .onStateChange { newState in
          print(newState.isValid)
          textFieldState = newState
        }
        .textFieldPadding(paddings)
        .border(color: (textFieldState?.isValid ?? true) ? validColor : invalidColor, lineWidth: 1)
        .frame(height: 54)
    }
  }
}
```

## VGSBlinkCardControllerRepresentable
VGSBlinkCardControllerRepresentable is a SwiftUI wrapper around BlinkCard card scanner controller and have similar attributes and functionality represented in SwiftUI way.

### Code example

```swift
struct CardDataCollectionSwiftUI: View {
    /// Track BlinkCard visibility status
    @State private var showingBlinkCardScanner = false
    /// Match scanned data with apropriate text fields.
    @State private var scanedDataCoordinators: [VGSBlinkCardDataType: VGSCardScanCoordinator] = [
            .cardNumber: VGSCardScanCoordinator(),
            .name: VGSCardScanCoordinator(),
            .cvc: VGSCardScanCoordinator(),
            .expirationDate: VGSCardScanCoordinator()
        ]
         
    // MARK: - Build View
    var body: some View {
        /// setup VGSConfiguration for fields 
        /// ...
      return VStack(spacing: 8) {
        VGSTextFieldRepresentable(configuration: holderNameConfiguration)
          .placeholder("Cardholder Name")
          .cardScanCoordinator(scanedDataCoordinators[.name]!)
        VGSCardTextFieldRepresentable(configuration: cardNumConfiguration)
          .placeholder("4111 1111 1111 1111")
          .cardScanCoordinator(scanedDataCoordinators[.cardNumber]!)
        HStack(spacing: 20) {
          VGSExpDateTextFieldRepresentable(configuration: expDateConfiguration)
            .placeholder("MM/YY")
            .cardScanCoordinator(scanedDataCoordinators[.expirationDate]!)
          VGSCVCTextFieldRepresentable(configuration: cvcConfiguration)
            .placeholder("CVC")
            .cardScanCoordinator(scanedDataCoordinators[.cvc]!)
            .setSecureTextEntry(true)
        }
        HStack(spacing: 20) {
          Button(action: {
            showingBlinkCardScanner = true
          }) {
              Text("SCAN")
                  .padding()
                  .cornerRadius(8)
                  .overlay(
                      RoundedRectangle(cornerRadius: 10)
                          .stroke(Color.blue, lineWidth: 2)
                  )
          }
          .fullScreenCover(isPresented: $showingBlinkCardScanner) {
            VGSBlinkCardControllerRepresentable(licenseKey: AppCollectorConfiguration.shared.blinkCardLicenseKey!, dataCoordinators: scanedDataCoordinators) { (errorCode) in
              print(errorCode)
            }.allowInvalidCardNumber(true)
            .onCardScanned({
              showingBlinkCardScanner = false
            })
            .onCardScanCanceled({
              showingBlinkCardScanner = false
            })
          }
        }
      }
    }
}
```
