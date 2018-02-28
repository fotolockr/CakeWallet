//
//  ReceiveView.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit
import SnapKit

final class ShadowedLabel: UILabel {
    var insets : UIEdgeInsets = UIEdgeInsets() {
        didSet {
            super.invalidateIntrinsicContentSize()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        addShadowView()
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom
        return size
    }
    
    override open func drawText(in rect: CGRect) {
        return super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}

extension UIView {
    func addShadowView() {
        superview?.viewWithTag(119900)?.removeFromSuperview()
        let shadowView = UIView(frame: frame)
        
        // Fix me: hardcode.
        
        shadowView.tag = 119900
        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 3)
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOpacity = 0.15
        shadowView.layer.shadowRadius = 25
        shadowView.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        shadowView.layer.rasterizationScale = UIScreen.main.scale
        shadowView.layer.shouldRasterize = true
        
        superview?.insertSubview(shadowView, belowSubview: self)
    }
}

final class ReceiveView: BaseView {
    private static let qrImageViewSize = CGSize(width: 175, height: 175)
    let qrImageView: UIImageView
    let addressLabel: UILabel
    let amountTextField: UITextField
    
    required init() {
        amountTextField = FloatingLabelTextField(placeholder: "Amount (optional)", title: "Amount")
        qrImageView = UIImageView()
        addressLabel = UILabel(font: .avenirNextMedium(size: 17))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        addressLabel.numberOfLines = 0
        addressLabel.isUserInteractionEnabled = true
        addressLabel.numberOfLines = 0
        addressLabel.textAlignment = .center
        addressLabel.textColor = UIColor(hex: 0xA682FF) // FIX-ME: Unnamed constant
        amountTextField.keyboardType = .decimalPad
        addSubview(qrImageView)
        addSubview(addressLabel)
        addSubview(amountTextField)
    }
    
    override func configureConstraints() {
        qrImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(25)
            make.width.equalTo(ReceiveView.qrImageViewSize.width)
            make.height.equalTo(ReceiveView.qrImageViewSize.height)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.width.equalTo(addressLabel.snp.width)
            make.height.equalTo(addressLabel.snp.height)
            make.top.equalTo(qrImageView.snp.bottom).offset(25)
            make.leading.equalTo(25)
            make.trailing.equalTo(-25)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.top.equalTo(addressLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
}
