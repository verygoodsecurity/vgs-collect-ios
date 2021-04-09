<p align="center"><a href="https://www.verygoodsecurity.com/"><img src="https://avatars0.githubusercontent.com/u/17788525" width="128" alt="VGS Logo"></a></p>
<p align="center"><i>Integration of VGS Collect iOS SDK with VGS Muptiplexing App</i></p>

The [VGS Multiplexing](https://github.com/verygoodsecurity/multiplexing/blob/master/integration/README.md) app facilitates payment multiplexing with integrations to 120+ gateways. This example shows how you can secure data through VGS Collect iOS SDK while using our payment gateway multiplexer.

## Flow diagram

<p align="center">
  <img src="https://api.media.atlassian.com/file/804e00b0-78b7-4738-b6f5-a82224a5e8af/binary?token=eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI5N2Y2ODMyNS0yNTlhLTQxZjAtYWQyNi1iYjA4ZmVjZWQyZGQiLCJhY2Nlc3MiOnsidXJuOmZpbGVzdG9yZTpmaWxlOjgwNGUwMGIwLTc4YjctNDczOC1iNmY1LWE4MjIyNGE1ZThhZiI6WyJyZWFkIl19LCJleHAiOjE2MTgwMDYyMjUsIm5iZiI6MTYxNzkyMzI0NX0.FGxs70deJGR5iqb1Ew7Bz467E2KxpTkURST0o5OTUiE&client=97f68325-259a-41f0-ad26-bb08feced2dd&name=multiplexing-runtime-flow.png" />
</p>

## How to run multiplexing sample

1. Follow the instructions and install [Multiplexing](https://github.com/verygoodsecurity/multiplexing/blob/master/integration/README.md) app.

2. Change `vaultId` to your vault id in `AppCollectorConfiguration` associated with Multiplexing setup.

3. Run `DemoApp` and select `Collect Card for Multiplexing`.

4. Fill in form with valid card data and press `Upload`. With provided Collect setup, form will make a request to the `/api/v1/financial_instruments` endpoint with the following data structure:

```
{
  "data": {
    "type":"financial_instruments",
    "attributes": {
      "instrument_type":"card",
      "details": {
        "first_name":"John",
        "last_name":"Doe",
        "number":"4111111111111111",
        "month":"1",
        "year":"2029",
        "verification_value":"111"
      }
    }
  }
}
```
