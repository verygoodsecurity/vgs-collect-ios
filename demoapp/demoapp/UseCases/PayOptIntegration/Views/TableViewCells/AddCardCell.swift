//
//  AddCardCell.swift
//  demoapp
//

import UIKit
import VGSCollectSDK

class AddCardCell: UITableViewCell {
  
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var checkboxImageView: UIImageView!
	@IBOutlet fileprivate weak var overlayView: UIView!
  
  var cardHolderName = VGSTextField()
  var cardNumber = VGSCardTextField()
  var expCardDate = VGSExpDateTextField()
  var cvcCardNum = VGSTextField()
  var zipCode = VGSTextField()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()

    setupStackViewUI()
		overlayView.layer.borderColor = UIColor.darkGray.cgColor
  }
  
  func setSelected(_ selected: Bool) {
    checkboxImageView.image = selected ? UIImage(named: "circle-checkbox-full") : UIImage(named: "circle-checkbox")
    
      stackView.isHidden = !selected
			// stackView.isHidden = true

		if isSelected {
			overlayView.layer.borderWidth = 1
		} else {
			overlayView.layer.borderWidth = 0
		}
  }
  
  private func setupStackViewUI() {
    stackView.addArrangedSubview(cardHolderName)
    stackView.addArrangedSubview(cardNumber)

		stackView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
		stackView.isLayoutMarginsRelativeArrangement = true
    
    let bottomStackView = UIStackView.init(arrangedSubviews: [expCardDate, cvcCardNum, zipCode])
    bottomStackView.axis = .horizontal
    bottomStackView.alignment = .fill
    bottomStackView.distribution = .fillEqually
    bottomStackView.spacing = 2
    stackView.addArrangedSubview(bottomStackView)

//		bottomStackView.layer.borderWidth = 1
//		bottomStackView.layer.cornerRadius = 4
//		bottomStackView.layer.borderColor = UIColor.lightGray.cgColor
  }
  
  func setupVGSTextFieldsConfiguration(with vgsCollect: VGSCollect) {
    /// Cardholder name config
    let holderConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "card.name")
    holderConfiguration.type = .cardHolderName
    holderConfiguration.keyboardType = .namePhonePad
    cardHolderName.textAlignment = .natural
    cardHolderName.configuration = holderConfiguration
    cardHolderName.placeholder = "Cardholder Name"
    
    /// Card number config
    let cardConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "card.number")
    cardConfiguration.type = .cardNumber
    cardConfiguration.isRequiredValidOnly = true
    cardNumber.configuration = cardConfiguration
    cardNumber.placeholder = "4111 1111 1111 1111"
    cardNumber.textAlignment = .natural
    cardNumber.cardIconLocation = .right
    
    /// Card Exp Date config
    let expDateConfiguration = VGSExpDateConfiguration(collector: vgsCollect, fieldName: "card.exp_date")
    expDateConfiguration.isRequiredValidOnly = true
    // Change input and output format
    expDateConfiguration.inputDateFormat = .shortYear
    expDateConfiguration.outputDateFormat = .longYear
    /// Set serializer(send month and year as separate fields)
    expDateConfiguration.serializers = [VGSExpDateSeparateSerializer(monthFieldName: "card.exp_month", yearFieldName: "card.exp_year")]
    expDateConfiguration.inputSource = .keyboard
    expCardDate.configuration = expDateConfiguration
    expCardDate.placeholder = "MM/YY"

    /// CVC  config
    let cvcConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "card.cvc")
    cvcConfiguration.isRequiredValidOnly = true
    cvcConfiguration.type = .cvc
    cvcCardNum.configuration = cvcConfiguration
    cvcCardNum.isSecureTextEntry = true
    cvcCardNum.placeholder = "CVC"

    /// Zip Code config
    let zipConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "card.billing_address.postal_code")
    zipConfiguration.isRequiredValidOnly = true
    zipConfiguration.type = .none
    /// Limit input symbols and length
    zipConfiguration.formatPattern = "#####"
    /// Setup custom validation for field
    zipConfiguration.validationRules = VGSValidationRuleSet(rules: [
                                  VGSValidationRulePattern(pattern: "^([0-9]{5})(?:-([0-9]{4}))?$",
                                                           error: "Wrong zip code")])
    zipCode.configuration = zipConfiguration
    zipCode.placeholder = "Billing Zip"
    
    /// Setup UI
    vgsCollect.textFields.forEach { textField in
			textField.translatesAutoresizingMaskIntoConstraints = false
			textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
			textField.textColor = UIColor.inputBlackTextColor
			textField.font = .systemFont(ofSize: 22)
			textField.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
			textField.tintColor = .lightGray
      textField.delegate = self
    }
//
//		cvcCardNum.borderWidth = 0
//		expCardDate.borderWidth = 0
//		zipCode.borderWidth = 0
  }
}

extension AddCardCell: VGSTextFieldDelegate {
  func vgsTextFieldDidChange(_ textField: VGSTextField) {
    /// Update border after validation
    textField.borderWidth = 0
  }
}
