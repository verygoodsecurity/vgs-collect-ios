[![CircleCI](https://circleci.com/gh/verygoodsecurity/vgs-collect-ios/tree/dev.svg?style=svg&circle-token=ec7cddc71a1c2f6e99843ef56fdb6898a2ef8f52)](https://circleci.com/gh/verygoodsecurity/vgs-collect-ios/tree/dev)
[![license](https://img.shields.io/github/license/verygoodsecurity/vgs-ios-sdk.svg)]()

## VGS Collect mobile SDK

VGS Collect - is a product suite that allows customers to collect information securely without possession of it. VGS Collect mobile SDKs - are native mobile forms modules that allow customers to collect information securely on mobile devices with iOS and Android

# Problem
Customers want to use VGS with their native mobile apps on iOS and Android devices. They want to get the same experience that they have on Web with VGS `Collect.js`.

# Goal
Customers can use the same VGS Vault and the same server-side for Mobile apps as for Web. Their experience should stay the same and be not dependent on the platform they use: Web or Mobile.

# Integration
The SDK has simple possibility for integration. For integration need to install the latest version of `cocoapods`.

1. Make a projects on the `xcode`
2. Open the terminal and go to the project folder
3. Make a Podfile (command: `pod init`)
4. Open the Podfile and insert next line

	```
	pod 'VGSCollectSDK'
	```

5. Back to terminal and put command `pod install`
6. Open `<your_project_name>.xcworkspace`
7. Open ViewController
8. Put next code to your controller

````
import VGSCollectSDK

class ViewController: UIViewController {
    // VGS Collect
    var vgsForm = VGSCollect(id: "your_tnt_id", environment: .sandbox)
    // VGS UI Elements
    var cardNumber = VGSTextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Observing statuses
        vgsForm.observeForm = { [weak self] form in
            // receiving text field statuses
        }
        
        let cardConfig = VGSConfiguration(collector: vgsForm, fieldName: "cardNumber")
        cardConfig.type = .cardNumber
        cardConfig.placeholder = "card number"
        cardNumber.configuration = cardConfig
        
        cardNumber.frame = CGRect(x: 10, y: 55, width: 310, height: 35)
        view.addSubview(cardNumber)
     }
}
````

# Styling you VGS text fields

You can use general property for customise your text fields.

Example: 

````
// set UI style
cardNumber.borderWidth = 1
cardNumber.borderColor = .lightGray
cardNumber.padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
cardNumber.textColor = .magenta
````


# Technologies what we use:
- Swift 4.2
- 3th party lib:
    - Alamofire
- Git, Continuous 
- Testing solutions: Unit Tests