# Collect+PaymentOrchestration

## Overview

VGS Collect iOS SDK can be used with VGS Payment Orchestration Service.
VGS Payment Orchestration offers an API to facilitate the routing of your payment transactions to 180+ gateways. With payment orchestration, payment facilitators and merchants are able to minimize their payment processing costs.

VGS offers Universal Checkout experience with VGS Checkout iOS SDK, complete checkout experience that is fully integrated with our payment optimization solution. 
VGS Checkout iOS SDK provides a separate presented page with Checkout form to collect card and billing information from customer.

In some cases you may want to build your own custom UI&UX checkout experience with VGS Payment Orchestration. For this purpose you can use VGS Collect iOS SDK to collect PCI card data and send it to Payment Orchestration. 

## Steps to integrate Collect with Payment Orchestration

###1.Implement your custom backend and iOS API client to fetch access token valid for Payment Orchestration operations.  

###2. Setup VGS Collect instance.

###3. Build your own UI with `VGSTextFields` and connect `VGSCollect` instance with fields.

###4. Build your own UI with `VGSTextFields` and connect `VGSCollect` instance with fields. 

###5. Collect payment data. Payload structure collected with VGS Collect should meet Payment Orchestration requirements.

```JSON
{
  "card": {
    "name": "John Doe",
    "number": "4242 4242 4242 4242",
    "exp_month": "05",
    "exp_year": "2035",
    "cvc": "123"
  }
}
```

###5. Send collected data to Payment Orchestration and create financial instrument. Don't forget to set authorization token. 

```swift
   		vgsCollectNewCardFlow.customHeaders = ["Authorization": "Bearer \(payOptAccessToken)"]
		/// Send card data to "financial_instruments" path
		vgsCollectNewCardFlow.sendData(path: "/financial_instruments", routeId: AppCollectorConfiguration.shared.paymentOrchestrationDefaultRouteId) { [weak self] response in
			switch response {
			case .success(_, let data, _):
				/// Get fin instrument from response data
				guard let finId = self?.apiClient.financialInstrumentID(from: data) else {
					print("can't parse fin_id from data!")
					return
				}
				/// Save fin instrument in shared config
				AppCollectorConfiguration.shared.savedFinancialInstruments.append(finId)
				/// Make deposit request
				self?.deposit(50, finId: finId)
			case .failure(let code,  _, _, let error):
				print("\(code) + \(String(describing: error))")
				return
			}
		}
```

###6. If needed store created financial instruments on your side to display saved cards in future.

### 7.Check `CollectPayoptIntegrationViewConroller` for more info.


  
