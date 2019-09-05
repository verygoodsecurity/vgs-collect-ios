## VGS Collect mobile SDKs

VGS Collect - is a product suite that allows customers to collect information securely without possession of it. VGS Collect mobile SDKs - are native mobile forms modules that allow customers to collect information securely on mobile devices with iOS and Android

# Problem
Customers want to use VGS with their native mobile apps on iOS and Android devices. They want to get the same experience that they have on Web with VGS Collect.js.

# Goal
Customers can use the same VGS Vault and the same server-side for Mobile apps as for Web. Their experience should stay the same and be not dependent on the platform they use: Web or Mobile.

# Step-by-step for integration
The VGSFramework has simple possibility for integration. For integration need to install the latest version of cocoapods.

1. Make a projects on the xcode
2. Open the terminal and go to the project folder
3. Make a Podfile (command: `pod init`)
4. Open the Podfile and insert next line

`pod 'VGSFramework', :git => https://github.com/verygoodsecurity/vgs-collect-ios`

5. Back to terminal and put command `pod install`
6. Open <your_project_name>.xcworkspace
7. Open ViewController
8. Put next code to your controller
````
import VGSFramework

class ViewController: UIViewController {
    // VGS Form
    var vgsForm = VGSForm(tnt: "your_tnt_id", environment: .sandbox)
    // VGS UI Elements
    var cardNumber = VGSTextField()
    // the Send data Button
    var sendButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Observing data
        vgsForm.observeForm = { [weak self] form in
            // receiving text field statuses
        }
        
        // setup card number text field
        view.addSubview(cardNumber)
        cardNumber.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.top.equalTo(cardHolderName.snp.bottom).offset(10)
        }
    }
}
````
