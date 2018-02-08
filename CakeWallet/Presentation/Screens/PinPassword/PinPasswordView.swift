//
//  final class PinPasswordView.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit
import FontAwesome_swift

final class PinPasswordView: BaseView {
    let stackView: UIStackView
    let keyboard: PasswordKeyboardView
    let descriptionLabel: UILabel
    let gradientLayer: CAGradientLayer
    var closeButton: UIButton?
    
    required init() {
        stackView = UIStackView(arrangedSubviews: [PinView(), PinView(), PinView(), PinView()])
        keyboard = PasswordKeyboardView()
        descriptionLabel = UILabel(font: UIFont.avenirNextMedium(size: 17))
        gradientLayer = CAGradientLayer()
        super.init()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    override func configureView() {
        super.configureView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = UIColor(hex: 0x303030) // FIX-ME: Unnamed constant
        
        backgroundColor = UIColor(hex: 0xF5F7F9) // FIX-ME: Unnamed constant
        
        
//        let startColor = UIColor(hex: 0xA682FF)
//        let endColor = UIColor(hex: 0xF5B0CB)

//        gradientLayer.frame = self.bounds
//        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
//        layer.insertSublayer(gradientLayer, at: 0)
        
        addSubview(stackView)
        addSubview(keyboard)
        addSubview(descriptionLabel)
    }
    
    override func configureConstraints() {
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(keyboard.snp.top).offset(-50)
            make.width.equalTo(200)
        }
        
        stackView.arrangedSubviews.forEach {
            $0.backgroundColor = .clear
            $0.snp.makeConstraints({ make in
                make.size.equalTo(CGSize(width: 24, height: 24))
            })
        }
        
        keyboard.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-25)
            make.height.equalToSuperview().dividedBy(2)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(stackView.snp.top).offset(-50)
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
        }
    }
    
    func addCloseButton() {
        if let closeButton = self.closeButton {
            closeButton.isHidden = false
            return
        }
        
        let closeButton = UIButton(type: .custom)
        closeButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25)
        closeButton.setTitle(String.fontAwesomeIcon(name: .close), for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(25)
        }
        
        layoutIfNeeded()
        
        self.closeButton = closeButton
    }
}
