//
//  PaymentCardCell.swift
//  demoapp


import UIKit
import VGSCollectSDK

class PaymentCardCell: UITableViewCell {
  
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var subtitle: UILabel!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var checkboxImageView: UIImageView!
  var cvcCardNum = VGSTextField()
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupVGSTextFieldUI()
    stackView.addArrangedSubview(cvcCardNum)
  }
  
  func setupVGSTextFieldUI() {
    cvcCardNum.textColor = .black
    cvcCardNum.backgroundColor = .groupTableViewBackground
    cvcCardNum.font = .systemFont(ofSize: 18)
    cvcCardNum.padding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    cvcCardNum.tintColor = .lightGray
    cvcCardNum.borderColor = .red
    cvcCardNum.borderWidth = 0
    cvcCardNum.cornerRadius = 0
    cvcCardNum.delegate = self
  }
  
  func setupVGSTextFieldConfiguration(_ vgsCollect: VGSCollect) {
    /// CVC  filed configuration
    let cvcConfiguration = VGSConfiguration(collector: vgsCollect, fieldName: "card.cvc")
    cvcConfiguration.isRequiredValidOnly = true
    cvcConfiguration.type = .none
    cvcConfiguration.formatPattern = "###"
    /// For Amex valid length should be 4 digits
    cvcConfiguration.validationRules = VGSValidationRuleSet(rules: [VGSValidationRuleLength(min: 3, max: 3, error: "Invalid CVC")])
    cvcCardNum.configuration = cvcConfiguration
    cvcCardNum.isSecureTextEntry = true
    cvcCardNum.placeholder = "CVC"
  }
  
  func setSelected(_ selected: Bool) {
    checkboxImageView.image = selected ? UIImage(named: "circle-checkbox-full") : UIImage(named: "circle-checkbox")
    cvcCardNum.cleanText()
    stackView.isHidden = !selected
  }
}

extension PaymentCardCell: VGSTextFieldDelegate {
  func vgsTextFieldDidChange(_ textField: VGSTextField) {
    /// Update border after validation
    textField.borderWidth = 0
  }
}
