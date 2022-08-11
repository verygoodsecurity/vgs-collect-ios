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
  
  var cardHolderName = VGSTextField()
  var cardNumber = VGSCardTextField()
  var expCardDate = VGSExpDateTextField()
  var cvcCardNum = VGSTextField()
  var zipCode = VGSTextField()
  var cardName = UITextField()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupStackViewUI()
    
    cardName.textColor = .black
    cardName.backgroundColor = .groupTableViewBackground
    cardName.font = .systemFont(ofSize: 18)
    cardName.tintColor = .lightGray
    cardName.layer.borderWidth = 0
    cardName.placeholder = "   Card name(optional)"
  }
  
  func setSelected(_ selected: Bool) {
    checkboxImageView.image = selected ? UIImage(named: "circle-checkbox-full") : UIImage(named: "circle-checkbox")
    
    stackView.isHidden = !selected
  }
  
  private func setupStackViewUI() {
    stackView.addArrangedSubview(cardHolderName)
    stackView.addArrangedSubview(cardNumber)
    
    let bottomStackView = UIStackView.init(arrangedSubviews: [expCardDate, cvcCardNum, zipCode])
    bottomStackView.axis = .horizontal
    bottomStackView.alignment = .fill
    bottomStackView.distribution = .fillEqually
    bottomStackView.spacing = 2
    stackView.addArrangedSubview(bottomStackView)
    stackView.addArrangedSubview(cardName)
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
      textField.textColor = .black
      textField.backgroundColor = .groupTableViewBackground
      textField.font = .systemFont(ofSize: 18)
      textField.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
      textField.tintColor = .lightGray
      textField.borderColor = .red
      textField.borderWidth = 0
      textField.cornerRadius = 0
      textField.delegate = self
    }
  }
}

extension AddCardCell: VGSTextFieldDelegate {
  func vgsTextFieldDidChange(_ textField: VGSTextField) {
    /// Update border after validation
    textField.borderWidth = 0
  }
}
