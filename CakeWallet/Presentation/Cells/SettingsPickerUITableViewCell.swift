//
//  SettingsPickerUITableViewCell.swift
//  CakeWallet
//
//  Created by Cake Technologies 31.01.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit

final class SettingsPickerUITableViewCell<Item: Stringify>: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    typealias Action = ((Item) -> Void)?
    let pickerView: UIPickerView
    let pinckerTextField: UITextField
    private(set) var pickerOptions: [Item]
    private var action: Action
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        pickerView = UIPickerView()
        pinckerTextField = UITextField()
        pickerOptions = []
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureConstraints()
    }
    
    override func configureView() {
        super.configureView()
        accessoryView = pinckerTextField
        pinckerTextField.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    override func configureConstraints() {
        pinckerTextField.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(pinckerTextField.snp.width)
        }
    }
    
    func configure(title: String, pickerOptions: [Item], selectedOption: Int = 0, action: Action) {
        self.textLabel?.text = title
        self.pickerOptions = pickerOptions
        self.action = action
        pickerView.reloadAllComponents()
        pickerView.selectRow(selectedOption, inComponent: 0, animated: false)
        pinckerTextField.text = pickerOptions[selectedOption].stringify()
    }
    
    // MARK: UIPickerViewDelegate
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard pickerOptions.count >= row else {
            return ""
        }
        
        return pickerOptions[row].stringify()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedOption = pickerOptions[row]
        pinckerTextField.text = selectedOption.stringify()
        action?(selectedOption)
    }
    
    // MARK: UIPickerViewDataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
}
