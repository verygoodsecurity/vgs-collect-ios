//
//  CreateCardViewController.swift
//  demoapp
//

import UIKit
import VGSCollectSDK

/// A demo screen for the form-driven CMP flow.
///
/// Responsibilities:
/// - Loads a `VGSCollect` session from a remote Form configuration.
/// - Binds card fields used for CMP create-card requests.
/// - Demonstrates optional card attributes lookup callbacks when the loaded Form enables them.
/// - Submits the collected data with `createCard(...)` and prints the response in the demo console.
///
/// CMP docs:
/// https://www.verygoodsecurity.com/docs/api/card-management#tag/card-management/POST/cards
class CreateCardViewController: UIViewController {

    @IBOutlet weak var cardDataStackView: UIStackView!
    @IBOutlet weak var consoleStatusLabel: UILabel!
    @IBOutlet weak var consoleLabel: UILabel!

    /// Collector is created asynchronously by loading a Form configuration.
    /// Keep a strong reference once loaded.
    private var vgsCollect: VGSCollect?

    // VGS UI Elements
    var cardNumber = VGSCardTextField()
    var expCardDate = VGSExpDateTextField()
    var cvcCardNum = VGSCVCTextField()

    var consoleMessage: String = "" {
        didSet { consoleLabel.text = consoleMessage }
    }
    /// Form name used to load form-driven config (CMP use-case).
    /// Keep this as app configuration (not user input).
    private let form = "test-form"

    /// Toggle between real Form config loading and a mocked "success" path (no network).
    /// Useful for UI dev / tests when you don't want to depend on remote Form config.
    private let useMockedSessionLoad = false

    override func viewDidLoad() {
      super.viewDidLoad()

      setupUI()
      setSubmitEnabled(false)

      if useMockedSessionLoad {
          mockLoadCollectorSessionAndConfigure()
      } else {
          loadCollectorSessionAndConfigure()
      }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        Task { @MainActor in
            let view = self.view
            if UITestsMockedDataProvider.isRunningUITest {
                view?.accessibilityIdentifier = "CreateCardViewController.Screen.RootView"
            }
        }
    }

    // MARK: - Init UI
    private func setupUI() {

        cardDataStackView.addArrangedSubview(cardNumber)
        cardDataStackView.addArrangedSubview(expCardDate)
        cardDataStackView.addArrangedSubview(cvcCardNum)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        consoleLabel.addGestureRecognizer(tapGesture)
        consoleLabel.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }

    private func setSubmitEnabled(_ enabled: Bool) {
        // This VC wiring uses storyboard for the button; we keep it lightweight by only updating status.
        consoleStatusLabel.text = enabled ? "STATE: Ready" : "STATE: Loading…"
    }

    @objc
    func hideKeyboard() {
        view.endEditing(true)
        consoleLabel.endEditing(true)
    }

    /// Mocked "session load" that always succeeds.
    /// This does NOT fetch a Form config; it creates a collector locally and applies default field configs.
    private func mockLoadCollectorSessionAndConfigure() {
        let collector = VGSCollect(
            id: AppCollectorConfiguration.shared.vaultId,
            environment: AppCollectorConfiguration.shared.environment.rawValue
        )

        self.vgsCollect = collector
        self.setSubmitEnabled(true)

        // Callbacks examples (will only run if your configs/form enable attributes lookup).
        self.setupCardAttributesLookupCallbacks(on: collector)

        // In mocked mode we must provide explicit configurations.
        self.setupElementsConfiguration(with: collector)
        self.setupStateObservation(on: collector)

        self.consoleStatusLabel.text = "STATE: Ready (mocked config)"
    }

    /// Loads collector session with Form configuration, then sets up callbacks.
    /// Note: when using Form config, field configuration comes from the Form itself.
    private func loadCollectorSessionAndConfigure() {
        VGSCollect.session(
            with: form,
            vaultId: AppCollectorConfiguration.shared.vaultId,
            environment: AppCollectorConfiguration.shared.environment,
            dataRegion: nil
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let collector):
                self.vgsCollect = collector
                self.setSubmitEnabled(true)

                self.setupCardAttributesLookupCallbacks(on: collector)

                // IMPORTANT: Form config is applied internally by the SDK when the session loads.
                self.setupElementsConfiguration(with: collector)
                self.setupStateObservation(on: collector)

            case .failure(_, _, _, let error):
                self.consoleStatusLabel.text = "STATE: Failed to load"
                self.consoleLabel.text = "Error: \(error?.localizedDescription ?? "Unknown error")"
            }
        }
    }

    /// Apply shared UI styling + delegates without touching configuration.
    private func applyCommonFieldUI(with collector: VGSCollect) {
        collector.textFields.forEach { textField in
            textField.textColor = UIColor.inputBlackTextColor
            textField.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            textField.tintColor = .lightGray
            textField.delegate = self
        }
    }

    private func setupStateObservation(on collector: VGSCollect) {
        // Observing text fields. The callback returns all textfields with updated states.
        // You can also use VGSTextFieldDelegate instead.
        collector.observeStates = { [weak self] textFields in
            var invalidTextFieldsCount = 0
            self?.consoleMessage = ""
            textFields.forEach({ textField in
                self?.consoleMessage.append(textField.state.description)
                self?.consoleMessage.append("\n")
                if !textField.state.isValid { invalidTextFieldsCount += 1 }
            })
            let formStateMsg = invalidTextFieldsCount > 0 ? "Not valid fields - \(invalidTextFieldsCount)!" : "All Valid!"
            self?.consoleStatusLabel.text = "STATE: \(formStateMsg)"
        }
    }

    /// Card attributes lookup is optional and is driven by Form config.
    /// If the Form includes includedCardAttributes, the SDK may trigger lookup on 11 digits.
    private func setupCardAttributesLookupCallbacks(on collector: VGSCollect) {
        // Provide a short-lived JWT token for card attributes lookup   https://www.verygoodsecurity.com/docs/api/card-management#tag/card-management/POST/cards
        // Never log or persist this token.
        collector.authHandler = { completion in
            // Replace with your own token provider.
            let token = "<fetch-token-from-your-backend-func()>"
            completion(.success(token))
        }

        collector.willBeginCardAttributesLookup = { [weak self] in
            // Example: show spinner / disable submit.
            self?.consoleStatusLabel.text = "STATE: Looking up card attributes…"
        }

        collector.didRetrieveCardAttributes = { [weak self] attributes in
            // Example: update UI with non-sensitive metadata like issuer / type.
            // Avoid logging PAN or JWT.
            self?.consoleStatusLabel.text = "STATE: Attributes received"
            self?.consoleLabel.text = "Card attributes: \(attributes)"
        }

        collector.didFailToRetrieveCardAttributes = { [weak self] code, _, response, error in
            // Backend, network, and SDK parsing failures all arrive here.
            // Example: hide spinner and proceed without enrichment.
            self?.consoleStatusLabel.text = "STATE: Attributes lookup failed"
            self?.consoleLabel.text = "Lookup error: \(code) response=\((response as? HTTPURLResponse)?.statusCode ?? -1) \(String(describing: error))"
        }
    }

    private func setupElementsConfiguration(with collector: VGSCollect) {
      /// Create default configurations for create card request. Default configurations include proper field names, validation, serializers. You also can edit default configuration.
      let cardConfiguration = VGSConfiguration.makeCardNumberConfiguration(collector: collector)
      cardNumber.configuration = cardConfiguration
      cardNumber.placeholder = "4111 1111 1111 1111"
      cardNumber.textAlignment = .natural

      let expDateConfiguration = VGSConfiguration.makeExpDateConfiguration(collector: collector)
      expCardDate.configuration = expDateConfiguration
      expCardDate.placeholder = "MM/YY"
      expCardDate.monthPickerFormat = .longSymbols

      let cvcConfiguration = VGSConfiguration.makeCVCConfiguration(collector: collector)
      cvcCardNum.configuration = cvcConfiguration
      cvcCardNum.isSecureTextEntry = true
      cvcCardNum.placeholder = "CVC"
      cvcCardNum.tintColor = .lightGray

      // Apply UI without overriding configuration.
      applyCommonFieldUI(with: collector)
  }

    // Upload data from TextFields to VGS
    @IBAction func uploadAction(_ sender: Any) {
      // hide keyboard
      hideKeyboard()

      guard let collector = vgsCollect else {
          consoleLabel.text = "Collector is not ready yet."
          return
      }

      // check if textfields are valid
      collector.textFields.forEach { textField in
        textField.borderColor = textField.state.isValid ? .lightGray : .red
      }
      /// Create card request(requires -authHandler(:) setup)
      collector.createCard(completion: { [weak self] response in
        self?.consoleStatusLabel.text = "RESPONSE"
        switch response {
        case .success(_, let data, _):
          if let data = data, let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            // swiftlint:disable force_try
            let response = (String(data: try! JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted), encoding: .utf8)!)
            // swiftlint:enable force_try
            self?.consoleLabel.text = "Success: \n\(response)"
            }
            return
        case .failure(let code, _, _, let error):
          self?.consoleLabel.text = "Submit request error: \(code), \(String(describing: error))"
          return
        }
      })
    }
}

// MARK: - VGSTextFieldDelegate
extension CreateCardViewController: VGSTextFieldDelegate {
  func vgsTextFieldDidChange(_ textField: VGSTextField) {
    textField.borderColor = textField.state.isValid  ? .gray : .red

    /// Update CVC field UI in case if valid cvc digits change, e.g.: input card number brand changed form Visa(3 digits CVC) to Amex(4 digits CVC)
    if textField == cardNumber, cvcCardNum.state.isDirty {
      cvcCardNum.borderColor =  cvcCardNum.state.isValid  ? .gray : .red
    }

    /// Check Card Number Field State with additional attributes (brand/bin/last4). Never log full PAN.
    if let cardState = textField.state as? VGSCardState, cardState.isValid {
        // Safe metadata-only log example: brand + last4 only.
        print("Card: \(cardState.cardBrand.stringValue) last4=\(cardState.last4)")
    }
  }
}
