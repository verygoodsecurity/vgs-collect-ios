[![CircleCI](https://circleci.com/gh/verygoodsecurity/vgs-collect-ios/tree/dev.svg?style=svg&circle-token=ec7cddc71a1c2f6e99843ef56fdb6898a2ef8f52)](https://circleci.com/gh/verygoodsecurity/vgs-collect-ios/tree/dev)
[![license](https://img.shields.io/github/license/verygoodsecurity/vgs-ios-sdk.svg)]()
[![swift](https://img.shields.io/badge/swift-4.2-orange)]()
[![UT](https://img.shields.io/badge/Unit_Test-pass-green)]()

# VGS Collect mobile SDK

VGS Collect - is a product suite that allows customers to collect information securely without possession of it. VGS Collect mobile SDKs - are native mobile forms modules that allow customers to collect information securely on mobile devices with iOS and Android

## Problem
Customers want to use VGS with their native mobile apps on iOS and Android devices. They want to get the same experience that they have on Web with VGS `Collect.js`.

## Goal
Customers can use the same VGS Vault and the same server-side for Mobile apps as for Web. Their experience should stay the same and be not dependent on the platform they use: Web or Mobile.

## Integration
The SDK has simple possibility for integration. For integration need to install the latest version of `cocoapods`.

1. Make a projects on the `xcode`
2. Open the terminal and go to the project folder
3. Make a Podfile (command: `pod init`)
4. Open the Podfile and insert next line

	```ruby
	pod 'VGSCollectSDK'
	```

5. Back to terminal and put command `pod install`
6. Open `<your_project_name>.xcworkspace`
7. Open ViewController
8. Put next code to your controller

````swift
import VGSCollectSDK

class ViewController: UIViewController {
    var vgsForm = VGSCollect(id: "your_tnt_id", environment: .sandbox)
    // VGS UI Elements
    var cardNumber = VGSTextField()
    
    var button = UIButton()
    
    // MARK: - Life cycle methods	
    override func loadView() {
        super.loadView()
        
        cardNumber.frame = CGRect(x: 10, y: 55, width: 310, height: 35)
        view.addSubview(cardNumber)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observing state of text fields
        vgsForm.observeStates = { [weak self] form in
            // receiving text fields status
            form.forEach { textField in
	            print(textField.status.description)
            }
        }
        
        // config text field
        let config = VGSConfiguration(collector: vgsForm, fieldName: "cardNumber")
				config.type = .cardNumber
        config.placeholder = "card number"
        cardNumber.configuration = config
        
        // add target for submit button
        button.addTarget(self, action: #selector(sendData(_:)), for: .touchUpInside)
     }
     
     @objc 
     func sendData(_ sender: UIButton) {
        // send extra data
        var extraData = [String: Any]()
        extraData["cardHolderName"] = "Joe Business"
        
        // send data
        vgsForm.submit(path: "/post", extraData: extraData, completion: { [weak self] (json, error) in
            // parse incoming data
        })
    }
}
````

## Styling your VGS text fields

You can use general property for customise your text fields.

Example: 

````swift
// set UI style
cardNumber.borderWidth = 1
cardNumber.borderColor = .lightGray
cardNumber.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
cardNumber.textColor = .magenta
cardNumber.font = UIFont(name: "Arial", size: 22)
````

## Upload files securely
For easy uploading file you can use VGSButton. 
Example:

````swift
class ViewController2: UIViewController {
    let vgsForm = VGSCollect(id: "tanent_id")
    @IBOutlet weak var selectFileButton: VGSButton! {
        didSet {
            button.presentViewController = self
        }
    }
    var submitButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.configuration = VGSConfiguration(collector: vgsForm, fieldName: "data")
        submitButton.addTarget(self, action: #selector(submit(_:)), for: .touchUpInside)
    }
    
    private func submit(_ sender: UIButton) {
        sender.isEnabled = false
        vgsForm.submitFiles(path: "/post", method: .post) { [weak self] (json, error) in
        
            sender.isEnabled = true
            
            if (error != nil) {
                print(error?.localizedDescription)
            } else {
                print(json)
            }
        }
    }
}
````