## Migration Guides

### Migrating from versions < v1.8.0
#### Swift PM modules updates.
`VGSPaymentCards` moved to separate module. For SDK integration with Swift Package Manager you need to import `VGSPaymentCards` module to each source file where you edit card brands.

Before:

```
import VGSCollectSDK
...

VGSPaymentCards.visa.regex = "\\d*$"
```

Now:
```
import VGSCollectSDK
import VGSPaymentCards
...

VGSPaymentCards.visa.regex = "\\d*$"
```

#### Rename enum 

### Migrating from versions < v1.7.3
#### Rename enum 
`CardExpDateFormat` -> `VGSCardExpDateFormat`

### Migrating from versions < v1.7.0
#### Carthage build modules changed for CardIO
If you use CardIO and integrate with Carthage, from now it's required to import `VGSCardIOCollector.framework` build in your application Target `Build Phases` and `Linkend Frameworks` settings.

Before:

Input Files
```
$(SRCROOT)/Carthage/Build/iOS/VGSCollectSDK.framework
$(SRCROOT)/Carthage/Build/iOS/CardIO.framework
```

Now:
```
$(SRCROOT)/Carthage/Build/iOS/VGSCollectSDK.framework
$(SRCROOT)/Carthage/Build/iOS/CardIO.framework
$(SRCROOT)/Carthage/Build/iOS/VGSCardIOCollector.framework
```

Same updates should be made for `Output Files`

Also in you project file where you use CardIO, you should import `VGSCardIOCollector` module:
```
import VGSCollectSDK
import VGSCardIOCollector
```

### Migrating from versions < v1.6.0
#### Updated namings

`SwiftLuhn` -> `VGSPaymentCards`
`SwiftLuhn.CardType`  -> `VGSPaymentCards.CardBrand`

#### Setup card number format pattern for each specific CardBrand
From now `.formatPattern` that was defined through `VGSConfiguration` will be ignored for fields with type `.cardNumber`. To be more flexible we released dynamic format patterns for each Payment Card Brand. Check our default format patterns in `VGSPaymentCards.swift` file, and update it if needed for each specific Card Model:

Before:
```
let cardConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "card_number")
cardConfiguration.type = .cardNumber
cardConfiguration.formatPattern = "#### #### #### ####"
```

Now:
```
VGSPaymentCards.amex.formatPattern = "#### ###### #####"
VGSPaymentCards.visa.formatPattern = "#### #### #### ####"
```

### Migrating from versions < v1.5.2
#### Is Secure field default attribute for CVC FieldType
Now default  `.isSecureTextEntry` value for `.cvc` field type is `false`. If you need secure entry, you can set it via `VGSTextField` attribute:

```
cvcTextField.isSecureTextEntry = true
```

### Migrating from versions < v1.5.0
#### Removed `Alamofire` dependecy, changed API methods

`Alamofire` networking manager removed from the SDK and related API methods removed too.<br/>
You should update `vgsCollect.submit(_:)` & `vgsCollect.submitFile(_:)` methods to `vgsCollect.sendData(_:)` & `vgsCollect.sendFile(_:)` accordingly. If you preferre to see new and old methods available together in same version, check `v1.4.2`.

Before:
```
vgsCollect.submit(path: "/post", method: .post, extraData: extraData, completion: { [weak self] (result, error) in
  if let data = result as? [String: Any] {
    //...
  }
})
```

Now:
```
vgsCollect.sendData(path: "/post", method: .post, extraData: extraData) { [weak self](result) in
  switch result {
    case .success(let code, let data, let response):
      if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
        //...
      }
      break
    case .failure(let code, let data, let response, let error):
        //...
      break
  }
}
```

Note that *completion* block also changed. Before `v1.5.0` you could get response data from *result* field in format `[String: Any]?`. Now response data is in `Data?` format, so you should convert it manually to the format you need. This allows us to handle any data type in response.<br/>
Before you could get some *error* objects as Alamofire's `AFError` type. Now you could get similar error types under the `NSURLErrorDomain` as `NSError`.

#### If you have issues with Cached `Alamofire` dependency
**Cocoapods** and **Carthage** cache project dependencies, so probably you will get errors when try to update `VGSCollectSDK` to the current version. Check the fix recommendations:

##### If you use Cocoapods:
Try to clean `DerivedData` folder for your project.<br/>
The location should look like: `~/Library/Developer/Xcode/DerivedData/your-project-id`.

##### If you use Carthage:
Carthage Caches usually stay at `~/Library/Caches/org.carthage.CarthageKit/dependencies/foobar`. You can remove  `Alamofire` dependencies there or follow the solution [here](https://github.com/Carthage/Carthage/issues/2786).

Also remove `Alamofire` dependencies from your project's `Target`. Check targets’ `Build Phases/Run Scripts` and `General/Frameworks, Libraries, and Emdedded Content` tabs.

### Migrating from versions < v1.3.5
#### Changed request data format for`.expDate` `FieldType`
We add divider `"/"` to input data by default when sending it to your *vault* from `VGSTextField` with `FieldType.expDate`

Before:
```
/// request body format example
{
  "customExpirationDateKey" : "0122"
}
```
Now:
```
/// request body format example
{
  "customExpirationDateKey" : "01/22"
}
```

Devider will be added by default. If you preferre to send data without divider, you can update textfield's  `VGSConfiguration.divider` attribute.<br/>
Send expiration date input without divider:
```
let expDateConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "customExpirationDateKey")
expDateConfiguration.type = .expDate
expDateConfiguration.divider = ""
```
