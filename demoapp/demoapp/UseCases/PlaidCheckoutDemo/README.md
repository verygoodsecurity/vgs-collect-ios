

# VGSPlaidLinkCollector

**VGSPlaidLinkCollector** - is an optional module that allows you to integrate [Paid Link SDK](https://plaid.com/docs/link/) with VGS Collect SDK.


## Before you start
- Create Link account - https://plaid.com/ .
- Setup and run demo backend - https://github.com/vgs-samples/collect-plaid-integration .
- Setup VGS routes https://dashboard.verygoodsecurity.com/ . You can find test routes in `.yaml` files inside our backend demo app.
- Set your organization details in `PlaidDemoConfiguration` class.

## Integration

### CocoaPods
Add PlaidLink pod to podfile:

```ruby
pod 'VGSCollectSDK/PlaidLink', :git => 'https://github.com/verygoodsecurity/vgs-collect-ios.git', :branch => 'feature/DEVX-167/plaid_integration'
```

In Terminal run `pod install` command.

### Swift Package Manager

Add  'VGSCollectSDK/VGSPlaidLinkCollector ' module to your App.

## Usage

### Add strong reference of `VGSPlaidLinkHandler` instance 
```
var linkHandler: VGSPlaidLinkHandler?

```
### Run Link Auth Flow

```
func openLinkAuth() {
  // Get Link token generated on backend
  guard let token = linkToken else {return}
  // Init VGSPlaidLinkHandler with `VGSCollect` instance and `linkToken`.
  self.linkHandler = VGSPlaidLinkHandler(collector: vgsCollect, linkToken: token, delegate: self)
  // Open Link flow
  self.linkHandler?.open(on: self)
}
```

### Handle Link flow results with `VGSPlaidLinkHandlerDelegate`

extension ViewController: VGSPlaidLinkHandlerDelegate {
  func didFinish(with metadata: [String : Any]) {
    /// Get public token on success Plaid Auth  flow completion
    guard let publicToken = metadata["public_token"] as? String else {
      print("❗PLAID PUBLIC TOKEN NOT FOUND!!!\n\(metadata)")
      return
    }
    ...
    /// Exchange public token to access token
    ...
    /// Get tokenized DDA account
    ...
  }
}
