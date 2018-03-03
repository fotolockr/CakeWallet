//
//  RestoreFromHeightView.swift
//  CakeWallet
//
//  Created by Cake Technologies on 21.02.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit
import SnapKit

final class RestoreFromHeightView: BaseView {
    let restoreHeightTextField: UITextField
    let dateTextField: UITextField
    let datePicker: UIDatePicker
    
    required init() {
        restoreHeightTextField = FloatingLabelTextField(placeholder: "Restore height (optional)")
        dateTextField = FloatingLabelTextField(placeholder: "Restore from date (optional)")
        datePicker = UIDatePicker()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        
        restoreHeightTextField.keyboardType = .numberPad
        datePicker.datePickerMode = .date
        dateTextField.inputView = datePicker
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(handleDatePicker), for: .valueChanged)
        addSubview(restoreHeightTextField)
        addSubview(dateTextField)
    }
    
    @objc
    private func handleDatePicker() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    override func configureConstraints() {
        let offsetBetweenFields = 20
        let fieldHeight = 50
        
        snp.makeConstraints { make in
            let height = (2 * fieldHeight) + offsetBetweenFields
            make.height.equalTo(height)
        }
        
        restoreHeightTextField.snp.makeConstraints { make in
            make.bottom.equalTo(dateTextField.snp.top).offset(offsetBetweenFields * -1)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(fieldHeight)
        }
        
        dateTextField.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(fieldHeight)
        }
    }
}

