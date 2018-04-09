//
//  ExchangeView.swift
//  CakeWallet
//
//  Created by Cake Technologies on 12.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit
import SnapKit
import FontAwesome_swift

final class ExchangeDepositCardView: UIView {
    let titleLabel: UILabel
    let cryptoTextField: UITextField
    let amountTextField: UITextField
    let refundTextField: UITextField
    let refundScanQr: UIButton
    let pickerView: UIPickerView
    
    init() {
        titleLabel = UILabel(font: .avenirNextMedium(size: 17))
        cryptoTextField = FloatingLabelTextField(placeholder: "Crypto")
        amountTextField = FloatingLabelTextField(placeholder: "Amount")
        refundTextField = FloatingLabelTextField(placeholder: "Refund address")
        refundScanQr = SecondaryButton(
            image: UIImage.fontAwesomeIcon(
                name: .qrcode,
                textColor: .gray,
                size: CGSize(width: 32, height: 32)))
        pickerView = UIPickerView()
        super.init(frame: .zero)
        configureView()
        configureConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func configureView() {
        super.configureView()
        titleLabel.text = "Deposit".uppercased()
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        amountTextField.keyboardType = .decimalPad
        cryptoTextField.inputView = pickerView
        pickerView.tag = 0
        backgroundColor = UIColor(hex: 0xE5ECF4)
        titleLabel.backgroundColor = UIColor.pictonBlue.withAlphaComponent(0.75)
        cryptoTextField.rightView = UIImageView(image: UIImage.fontAwesomeIcon(name: .angleDown, textColor: .pictonBlue, size: CGSize(width: 32, height: 32)))
        cryptoTextField.rightViewMode = .always
        layer.masksToBounds = true
        layer.cornerRadius = 10
        addSubview(titleLabel)
        addSubview(cryptoTextField)
        addSubview(amountTextField)
        addSubview(refundTextField)
        addSubview(refundScanQr)
    }
    
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(40)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        cryptoTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(cryptoTextField.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        refundTextField.snp.makeConstraints { make in
            make.top.equalTo(amountTextField.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(refundScanQr.snp.leading).offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        refundScanQr.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(refundTextField.snp.centerY)
            make.width.equalTo(50)
        }
    }
    
    func hideRefund() {
        refundTextField.isHidden = true
        refundScanQr.isHidden = true
    }
    
    func showRefund() {
        refundTextField.isHidden = false
        refundScanQr.isHidden = false
    }
}

final class ExchangeReceiveCardView: UIView {
    let titleLabel: UILabel
    let cryptoTextField: UITextField
    let amountLabel: UILabel
    let addressTextField: UITextField
    let addressScanQr: UIButton
    let pickerView: UIPickerView
    
    init() {
        titleLabel = UILabel(font: .avenirNextMedium(size: 17))
        cryptoTextField = FloatingLabelTextField(placeholder: "Crypto")
        amountLabel = UILabel(font: .avenirNextMedium(size: 13))
        addressTextField = FloatingLabelTextField(placeholder: "Address")
        addressScanQr = SecondaryButton(
            image: UIImage.fontAwesomeIcon(
                name: .qrcode,
                textColor: .gray,
                size: CGSize(width: 32, height: 32)))
        pickerView = UIPickerView()
        super.init(frame: .zero)
        configureView()
        configureConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func configureView() {
        super.configureView()
        titleLabel.text = "Receive".uppercased()
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        cryptoTextField.inputView = pickerView
        pickerView.tag = 1
        backgroundColor = UIColor(hex: 0xE5ECF4)
        titleLabel.backgroundColor = UIColor.pictonBlue.withAlphaComponent(0.75)
        layer.masksToBounds = true
        layer.cornerRadius = 10
        cryptoTextField.rightView = UIImageView(image: UIImage.fontAwesomeIcon(name: .angleDown, textColor: .pictonBlue, size: CGSize(width: 32, height: 32)))
        cryptoTextField.rightViewMode = .always
        addSubview(titleLabel)
        addSubview(cryptoTextField)
        addSubview(amountLabel)
        addSubview(addressTextField)
        addSubview(addressScanQr)
    }
    
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(40)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        cryptoTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(cryptoTextField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.height.equalTo(addressTextField.snp.height)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        addressTextField.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalTo(addressScanQr.snp.leading).offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        addressScanQr.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(addressTextField.snp.centerY)
            make.width.equalTo(50)
        }
    }
    
    func hideAddress() {
        addressTextField.isHidden = true
        addressScanQr.isHidden = true
    }
    
    func showAddress() {
        addressTextField.isHidden = false
        addressScanQr.isHidden = false
    }
}

final class ExchangeView: BaseView {
    let exchangeButton: UIButton
    let resetButton: UIButton
    let poweredByLabel: UILabel
    let depositView: ExchangeDepositCardView
    let receiveView: ExchangeReceiveCardView
    let scrollView: UIScrollView
    let showDetailsButton: UIButton
    let contentView: UIView
    
    required init() {
        exchangeButton = PrimaryButton(title: "Exchange".uppercased())
        resetButton = SecondaryButton(title: "RESET".uppercased())
        poweredByLabel = UILabel(font: .avenirNextMedium(size: 13))
        depositView = ExchangeDepositCardView()
        receiveView = ExchangeReceiveCardView()
        showDetailsButton = SecondaryButton(title: "Show details")
        scrollView = UIScrollView()
        contentView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        backgroundColor = .whiteSmoke
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        poweredByLabel.textAlignment = .center
        poweredByLabel.textColor = .lightGray
        contentView.isUserInteractionEnabled = true
        contentView.addSubview(exchangeButton)
        contentView.addSubview(poweredByLabel)
        contentView.addSubview(resetButton)
        contentView.addSubview(showDetailsButton)
        contentView.addSubview(receiveView)
        contentView.addSubview(depositView)
        scrollView.addSubview(contentView)
        addSubview(scrollView)
    }
    
    override func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.bottom.greaterThanOrEqualTo(self.safeAreaLayoutGuide.snp.bottom)
        }
        
        exchangeButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.leading.equalTo(self.snp.centerX).offset(10)
            
            switch UIScreen.main.sizeType {
            case .iPhone4, .iPhone5, .iPhone6:
                make.top.equalTo(poweredByLabel.snp.bottom).offset(20)
            default:
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-25)
            }
        }
        
        resetButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(exchangeButton.snp.width)
            make.trailing.equalTo(self.snp.centerX).offset(-10)
            
            switch UIScreen.main.sizeType {
            case .iPhone4, .iPhone5, .iPhone6:
                make.top.equalTo(poweredByLabel.snp.bottom).offset(20)
            default:
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-25)
            }
        }
    
        poweredByLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            
            switch UIScreen.main.sizeType {
            case .iPhone4, .iPhone5, .iPhone6:
                make.top.equalTo(receiveView.snp.bottom).offset(20)
            default:
                make.bottom.equalTo(exchangeButton.snp.top).offset(-15)
            }
        }
        
        depositView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        receiveView.snp.makeConstraints { make in
            make.top.equalTo(depositView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
//        showDetailsButton.snp.makeConstraints { make in
//            make.top.equalTo(bgReceiveView.snp.bottom).offset(20)
//            make.centerX.equalToSuperview()
//            make.height.equalTo(50)
//        }
    }
}
