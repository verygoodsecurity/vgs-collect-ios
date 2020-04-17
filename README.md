[![CircleCI](https://circleci.com/gh/verygoodsecurity/vgs-collect-ios/tree/master.svg?style=svg&circle-token=ec7cddc71a1c2f6e99843ef56fdb6898a2ef8f52)](https://circleci.com/gh/verygoodsecurity/vgs-collect-ios/tree/dev)
[![UT](https://img.shields.io/badge/Unit_Test-pass-green)]()
[![license](https://img.shields.io/github/license/verygoodsecurity/vgs-collect-ios.svg)]()
[![Platform](https://img.shields.io/cocoapods/p/VGSCollectSDK.svg?style=flat)](https://github.com/verygoodsecurity/vgs-collect-ios)
[![swift](https://img.shields.io/badge/swift-5-orange)]()
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/VGSCollectSDK.svg?style=flat)](https://cocoapods.org/pods/VGSCollectSDK)

# VGS Collect iOS SDK

VGS Collect - is a product suite that allows customers to collect information securely without possession of it. VGSCollect iOS SDK  allows you to securely collect data from your users via forms without having to have that data pass through your systems. The form fields behave like traditional input fields while securing access to the unsecured data.

Table of contents
=================

<!--ts-->
   * [Before you start](#before-you-start)
   * [Integration](#integration)
      * [CocoaPods](#cocoapods)
   * [Usage](#usage)
      * [Create VGSCollect instance and VGS UI Elements](#create-vgscollect-instance-and-vgs-ui-elements)
      * [Customize UI Elements](#customize-ui-elements)
      * [Observe Fields State](#observe-fields-state)
      * [Collect and Send Your Data](#collect-and-send-your-data)
      * [Scan Credit Card Data](#scan-credit-card-cata)
      * [Demo Application](#demo-application)
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

## Usage

### Create VGSCollect instance and VGS UI Elements
Use your `<vault-id>` to initialize VGSCollect instance. You can get it in your [organisation dashboard](https://dashboard.verygoodsecurity.com/).

### Usage

<table>
  <tr">
    <th >Here's an example</th>
    <th width="27%">In Action</th>
  </tr>
  <tr>
    <td>Customize  VGSTextFields...</td>
     <th rowspan="2"><img src="add-card.gif"></th>
  </tr>
  <tr>
    <td>
        
    import UIKit
    import VGSCollectSDK

    class ViewController: UIViewController {

        var vgsForm = VGSCollect(id: "<vault-id>", environment: .sandbox)

        // VGS UI Elements
        var cardNumber = VGSTextField()

        override func viewDidLoad() {
            super.viewDidLoad()

            // Configure Elements UI
            let cardConfig = VGSConfiguration(collector: vgsForm,
                                              fieldName: "cardNumber")
                                              
            // Submit only if cardNumber input is valid
            cardConfig.isRequiredValidOnly = true
            cardConfig.type = .cardNumber
            cardNumber.configuration = cardConfig
            
            // styling
            cardNumber.placeholder = "card number"
            cardNumber.borderWidth = 1
            cardNumber.borderColor = .lightGray
            cardNumber.textColor = .magenta
            cardNumber.font = UIFont(name: "Arial", size: 22)
            cardNumber.textAlignment = .natural

            view.addSubview(cardNumber)
        }
    }
    ...
  </td>
  </tr>
  <tr>
    <td>... observe filed states </td>
     <th rowspan="2"><img src="state.gif"></th>
  </tr>
  <tr>
    <td>
    
    // ...  
    
    // Observing text fields
    vgsForm.observeStates = { textFields in
    
        textFields.forEach({ textField in
               print(textField.state.description)
               
               if let cardState = textField.state as? CardState {
                    
                    if !cardState.isValid {
                        textField.borderColor = .red
                    } else {
		        print(cardState.bin)
		        print(cardState.last4)
		        print(cardState.brand.stringValue)
		    }   
               }
              
        })
    }
   
  </td>
  </tr>
  <tr>
    <td colspan="2">... send a data</td>
  </tr>
  <tr>
    <td colspan="2">
        
    //....

    // MARK: - Submit data    
    func sendData() {
        // extra information will be sent together with all sensitive card information
        var extraData = [String: Any]()
        extraData["cardHolderName"] = "Joe Business"

        // send data
        vgsForm.submit(path: "/post", extraData: extraData, completion: { (json, error) in
            if error == nil, let json = json {
                // parse response data
            } else {
                if let error = error as NSError?, let errorKey = error.userInfo["key"] as? String {
                    if errorKey == VGSSDKErrorInputDataRequiredValid {
                        // handle VGSError error
                    }
                } else {
                   // handle other errors 
                }
            }
        })
    }
  </td>
  </tr>
</table>

**VGSCardTextField** automatically detects card provider and display card brand icon in the input field.


### Scan Credit Card Data
VGSCollect provide secure [card.io](https://github.com/verygoodsecurity/CardIOSDK-iOS) integration for collecting and setting scanned data into ``VGSTextFields``. 
To use [card.io](https://github.com/verygoodsecurity/CardIOSDK-iOS) with **VGSCollectSDK** you should add **CardIO** module alongside with core **VGSCollectSDK** module into your App Podfile:
```ruby
pod 'VGSCollectSDK'
pod 'VGSCollectSDK/CardIO'
```

Also you need to add **<NSCameraUsageDescription>** key with camera usage description into your App ``Info.plist``.

#### Usage

<table>
  <tr>
    <th>Here's an example</th>
    <th width="25%">In Action</th>
  </tr>
  <tr>
    <td>Setup  VGSCardIOScanController...</td>
    <th rowspan="2"><img src="card-scan.gif"></th>
  </tr>
  <tr>
    <td>
    
    class ViewController: UIViewController {

	    var scanController = VGSCardIOScanController()
	    var scanButton = UIButton()

	    override func viewDidLoad() {
		super.viewDidLoad()

		// set VGSCardIOScanDelegate
		scanController.delegate = self
	    }
	    
	    @objc func scanData(_ sender: UIButton) {
		scanController.presentCardScanner(on: self,
						animated: true,
						completion: nil)
	    }
    }
  </td>
  </tr>
  <tr>
    <td colspan="2">... handle VGSCardIOScanControllerDelegate</td>
  </tr>
  <tr>
    <td colspan="2">
	    
    extension ViewController: VGSCardIOScanControllerDelegate {

	    //Asks VGSTextField where scanned data with type need to be set.
	    func textFieldForScannedData(type: CradIODataType) -> VGSTextField? {
		switch type {
		case .expirationDate:
		    return expCardDate
		case .cvc:
		    return cvcCardNum
		case .cardNumber:
		    return cardNumber
		default:
		    return nil
		}
	    }

	    //When user press Done button on CardIO screen
	    func userDidFinishScan() {
		scanController.dismissCardScanner(animated: true, completion: {
		    // add actions on scan controller dismiss completion
		})
	    }
    }
   
  </td>
  </tr>
</table>

Handle `VGSCardIOScanControllerDelegate` functions. To setup scanned data into specific  VGSTextField implement `textFieldForScannedData:` . If scanned data is valid it will be set in your VGSTextField automatically after user confirmation. Check  `CradIODataType` to get available scand data types.


### Upload Files

You can add a file uploading functionality to your application with **VGSFilePickerController**.

#### Usage

<table>
  <tr">
    <th  colspan="2>Here's an example</th>
  </tr>
  <tr>
    <td colspan="2">Setup  VGSFilePickerController...</td>
  </tr>
  <tr>
    <td colspan="2">
	    
    class FilePickerViewController: UIViewController, VGSFilePickerControllerDelegate {

	  // Create strong referrence of VGSFilePickerController
	  var pickerController: VGSFilePickerController?

	  // Collector vgs
	  var vgsCollect = VGSCollect(id: "vailtId", environment: .sandbox)


	  override func viewDidLoad() {
	      super.viewDidLoad()

	      // create picker configuration
	      let filePickerConfig = VGSFilePickerConfiguration(collector: vgsCollect,
	      							fieldName: "secret_doc",
							       fileSource: .photoLibrary)

	      // init picket controller with configuration
	      pickerController = VGSFilePickerController(configuration: filePickerConfig)

	      // handle picker delegates
	      pickerController?.delegate = self
	  }

	  // Present picker controller
	  private func selectFileFromSource() {
	      pickerController?.presentFilePicker(on: self, animated: true, completion: nil)
	  }
	}
	...
  </td>
  </tr>
  <tr>
    <td>... handle VGSFilePickerControllerDelegate</td>
    <th width="27%">In Action</th>
  </tr>
  <tr>
    <td>
	
	// ...  
	
	// Check file info, selected by user
	func userDidPickFileWithInfo(_ info: VGSFileInfo) {
		let fileInfo = """
			    File info:
			    - fileExtension: \(info.fileExtension ?? "unknown")
			    - size: \(info.size)
			    - sizeUnits: \(info.sizeUnits ?? "unknown")
			    """
		print(fileInfo)
		pickerController?.dismissFilePicker(animated: true)
	}

	// Handle cancel file selection
	func userDidSCancelFilePicking() {
		pickerController?.dismissFilePicker(animated: true)
	}

	// Handle errors on picking the file
	func filePickingFailedWithError(_ error: VGSError) {
		pickerController?.dismissFilePicker(animated: true)
	}
   
  </td>
  <td><img src="file-picker.gif"></td>
  </tr>
  <tr>
    <td colspan="2">... send a file</td>
  </tr>
  <tr>
    <td colspan="2">
	    
	//....

	// MARK: - Submit File	
	// Send file and extra data
	func submitAction(_ sender: Any) {
		let extraData = ["document_holder": "Joe B"]

		// send file data to VGS
		vgsCollect.submitFile(path: "/post", method: .post,
						  extraData: extraData) { [weak self](json, error) in

		    if error == nil, let json = json?["json"] {
			// remove file from VGSCollect storage
			self?.vgsCollect.cleanFiles()
		    } else {
			// handle the errors
		    }
		}
	}
  </td>
  </tr>
</table>


## Demo Application
Demo application for collecting card data on iOS is <a href="https://github.com/verygoodsecurity/vgs-collect-ios/tree/master/demoapp">here</a>.

### For more details check our documentation
https://www.verygoodsecurity.com/docs/vgs-collect/ios-sdk

## Dependencies
- iOS 10+
- Swift 5
- 3rd party libraries:
    - Alamofire

## License

 VGSCollect iOS SDK is released under the MIT license. [See LICENSE](https://github.com/verygoodsecurity/vgs-collect-ios/blob/master/LICENSE) for details.
