[![CircleCI](https://circleci.com/gh/verygoodsecurity/vgs-collect-ios/tree/master.svg?style=svg&circle-token=ec7cddc71a1c2f6e99843ef56fdb6898a2ef8f52)](https://circleci.com/gh/verygoodsecurity/vgs-collect-ios/tree/dev)
[![UT](https://img.shields.io/badge/Unit_Test-pass-green)]()
[![license](https://img.shields.io/github/license/verygoodsecurity/vgs-ios-sdk.svg)]()
[![Platform](https://img.shields.io/cocoapods/p/VGSCollectSDK.svg?style=flat)](https://github.com/verygoodsecurity/vgs-collect-ios)
[![swift](https://img.shields.io/badge/swift-5-orange)]()
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/VGSCollectSDK.svg?style=flat)](https://cocoapods.org/pods/VGSCollectSDK)

# VGS Collect iOS SDK

VGS Collect - is a product suite that allows customers to collect information securely without possession of it. VGSCollect iOS SDK  allows you to securely collect data from your users via forms without having to have that data pass through your systems. The form fields behave like traditional input fields while securing access to the unsecured data.

Table of contents
=================

<!--ts-->
   * [Before you start](#before-you-start)
   * [Integration](#integration)
      * [CocoaPods](#cocoapods)
      * [Swift Package Manager](#swift-package-manager-(-xcode-11+-))
   * [Usage](#usage)
      * [Create VGSCollect instance and VGS UI Elements](#create-vgscollect-instance-and-vgs-ui-elements)
      * [Customize UI Elements](#customize-ui-elements)
      * [Observe Fields State](#observe-fields-state)
      * [Collect and Send Your Data](#collect-and-send-your-data)
      * [Documentation](#for-more-details-check-our-documentation)
   * [Dependencies](#dependencies)
   * [License](#license)
<!--te-->

<p align="center">
	<img src="https://raw.githubusercontent.com/verygoodsecurity/vgs-collect-ios/canary/vgs-collect-ios-state.png" width="200" alt="VGS Collect iOS SDK State" hspace="20">
	<img src="https://raw.githubusercontent.com/verygoodsecurity/vgs-collect-ios/canary/vgs-collect-ios-response.png" width="200" alt="VGS Collect iOS SDK Response" hspace="20">
</p>


## Before you start
You should have your organization registered at <a href="https://dashboard.verygoodsecurity.com/dashboard/">VGS Dashboard</a>. Sandbox vault will be pre-created for you. You should use your `<vault-id>` to start collecting data. Follow integration guide below.

# Integration

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate VGSCollectSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'VGSCollectSDK'
```

### Swift Package Manager(Xcode 11+)

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

To add VGSCollectSDK package dependency to your Xcode project, select File > Swift Packages > Add Package Dependency. Enter package repository URL and press Next:

```ruby
https://github.com/verygoodsecurity/vgs-collect-ios
```
Now you need to choose which part of the code you want to look at, you can choose the dependency type(tagged version, branch or commit). Then Xcode will setup all the stuff for you. We recommend to choose `master` branch to get latest stable SDK version.

On Final screen check that you project target is correct and press Finish.



## Usage

### Create VGSCollect instance and VGS UI Elements
Use your `<vault-id>` to initialize VGSCollect instance. You can get it in your [organisation dashboard](https://dashboard.verygoodsecurity.com/).

````swift
import UIKit
import VGSCollectSDK

class ViewController: UIViewController {

  var vgsForm = VGSCollect(id: "<vault-id>", environment: .sandbox)

  // VGS UI Elements
  var cardNumber = VGSTextField()

  override func viewDidLoad() {
		super.viewDidLoad()

		// Configure Elements UI
		let cardConfig = VGSConfiguration(collector: vgsForm, fieldName: "cardNumber")
		cardConfig.placeholder = "card number"
		cardConfig.isRequired = true
		cardConfig.type = .cardNumber

		cardNumber.configuration = cardConfig

		cardNumber.frame = CGRect(x: 10, y: 55, width: 310, height: 35)
		view.addSubview(cardNumber)
    }
}
````

### Customize UI Elements
You can use general properties for styling your UI elements.

```swift
	// UI Elements styling
	cardNumber.borderWidth = 1
	cardNumber.borderColor = .lightGray
	cardNumber.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
	cardNumber.textColor = .magenta
	cardNumber.font = UIFont(name: "Arial", size: 22)
```
### Observe Fields State

```swift
	// Observing text fields
	vgsForm.observeStates = { textFields in
	    textFields.forEach({ textField in
	           print(textField.state.description)
	    })
	}
```
### Collect and Send Your Data

```swift
func sendData() {
    // extra information will be sent together with all sensitive card information
    var extraData = [String: Any]()
    extraData["cardHolderName"] = "Joe Business"

    // send data
    vgsForm.submit(path: "/post", extraData: extraData, completion: { (json, error) in
        if error == nil, let json = json {
            // parse response data
        } else {
            // handle error
        }
    })
}
```

### More useful UI component for bank card
You can use the VGSCardTextField if you want to see a card brand icon in the input field.

````swift
    // create VGSCardTextField instance
	var cardNumber = VGSCardTextField()
````

<p align="center">
	<img  src="https://raw.githubusercontent.com/verygoodsecurity/vgs-collect-ios/canary/cardTextField.png" width=“600">
</p>

### For more details check our documentation
https://www.verygoodsecurity.com/docs/vgs-collect/ios-sdk

## Dependencies
- iOS 10+
- Swift 5
- 3rd party libraries:
    - Alamofire

## License

 VGSCollect iOS SDK is released under the MIT license. [See LICENSE](https://github.com/verygoodsecurity/vgs-ios-sdk/blob/master/LICENSE) for details.
