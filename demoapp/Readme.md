# VGS Collect Credit Card Example + Multiplexing

The [VGS Multiplexing](https://github.com/verygoodsecurity/multiplexing/blob/master/integration/README.md) app facilitates payment multiplexing with integrations to 120+ gateways. This example shows how you can secure data through VGS Collect.js while using our payment gateway multiplexer.

## How to set up this example

1. Follow the instructions and install [Multiplexing](https://github.com/verygoodsecurity/multiplexing/blob/master/integration/README.md) app.

2. `Copy` and `Paste` the content of an `multiplexing.html` file into you application.

3. Change link below to the latest VGS Collect library link. You can find it at VGS Collect page of [VGS Dashboard](https://dashboard.verygoodsecurity.com/)

```html
<script src="https://js.verygoodvault.com/vgs-collect/<version>/vgs-collect.js"></script>
```
Full list of available versions with release notes you can find in our [Changelog](https://www.verygoodsecurity.com/docs/vgs-collect/js/changelog).

4. Change `<vault-id>` to your vault id to initialize your Collect form

```javascript
const form = VGSCollect.create('<vault-id>', '<environment>', function(state) {});
```

5. Submit the form!
