//
//  ExchangeTableViewCell.swift
//  CakeWallet
//
//  Created by Cake Technologies on 12.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class ExchangeTableViewCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var completionhandler: ((CryptoCurrency) -> Void)?
    var onWeightChange: ((Float) -> Void)?
    var onAddressChange: ((String) -> Void)?
    var weight: Float {
        get {
            let raw = weightTextField.text ?? ""
            return Float(raw) ?? 0.0
        }
        
        set {
            weightTextField.text = String(format: "%.2f", newValue)
            onWeightChange?(newValue)
        }
    }
    let cryptoTextField: UITextField
    let weightTextField: UITextField
    let addressTextField: UITextField
    let picker: UIPickerView
    let resultAmountLabel: UILabel
    private let options: [CryptoCurrency]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        cryptoTextField = FloatingLabelTextField(placeholder: "Crypto")
        weightTextField = FloatingLabelTextField(placeholder: "Weight %")
        addressTextField = FloatingLabelTextField(placeholder: "Address")
        picker = UIPickerView()
        options = CryptoCurrency.all
        resultAmountLabel = UILabel()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        picker.delegate = self
        picker.dataSource = self
        cryptoTextField.inputView = picker
        backgroundColor = .clear
        weightTextField.keyboardType = .decimalPad
        weightTextField.addTarget(self, action: #selector(onWeightChange(_:)), for: .editingDidEnd)
        addressTextField.addTarget(self, action: #selector(onAddressChange(_:)), for: .editingDidEnd)
        resultAmountLabel.text = "Test"
        resultAmountLabel.backgroundColor = .green
        addSubview(cryptoTextField)
        addSubview(weightTextField)
        addSubview(addressTextField)
        addSubview(resultAmountLabel)
    }
    
    override func configureConstraints() {
        cryptoTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalTo(weightTextField.snp.leading).offset(-10)
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        
        weightTextField.snp.makeConstraints { make in
            make.top.equalTo(cryptoTextField.snp.top)
            make.trailing.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
        }
        
        addressTextField.snp.makeConstraints { make in
            make.top.equalTo(cryptoTextField.snp.bottom).offset(15)
//            make.bottom.equalTo(resultAmountLabel.snp.top).offset(-15)
            make.leading.equalTo(cryptoTextField.snp.leading)
            make.trailing.equalTo(weightTextField.snp.trailing)
        }
        
        resultAmountLabel.snp.makeConstraints { make in
            make.top.equalTo(addressTextField.snp.bottom).offset(15)
            make.bottom.equalToSuperview().offset(-15)
            make.leading.equalTo(cryptoTextField.snp.leading)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        //resultAmountLabel
    }
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row].symbol
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selected = options[row]
        cryptoTextField.text = selected.symbol
        completionhandler?(selected)
    }
    
    @objc
    private func onWeightChange(_ textField: UITextField) {
        onWeightChange?(weight)
    }
    
    @objc
    private func onAddressChange(_ textField: UITextField) {
        onAddressChange?(textField.text ?? "")
    }
}
