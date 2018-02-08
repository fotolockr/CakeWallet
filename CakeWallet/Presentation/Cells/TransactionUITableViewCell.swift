//
//  TransactionUITableViewCell.swift
//  Wallet
//
//  Created by Cake Technologies 11/27/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit
import FontAwesome_swift

final class TransactionUITableViewCell: UITableViewCell {
    static private let defaultContentBackgroundColor = UIColor.white
    static private let imageSize = CGSize(width: 26, height: 26)
    let directionLabel: UILabel
    let amountLabel: UILabel
    let idLabel: UILabel
    let dateLabel: UILabel
    let feeLabel: UILabel
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        directionLabel = UILabel(font: .avenirNextDemiBold(size: 21))
        amountLabel = PaddingLabel(
            insets: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10),
            font: .avenirNextDemiBold(size: 17))
        idLabel = UILabel(font: .avenirNextMedium(size: 14))
        dateLabel = UILabel(font: .avenirNextMedium(size: 14))
        feeLabel = UILabel(font: .avenirNextDemiBold(size: 14))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        idLabel.textColor = .gray
        dateLabel.textColor = .gray
        feeLabel.textColor = .gray
        
        // FIX-ME: Unnamed constant
        
        directionLabel.textColor = UIColor(hex: 0x303030)
        amountLabel.layer.masksToBounds = true
        amountLabel.layer.cornerRadius = 10
        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 5
        contentView.addSubview(feeLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(directionLabel)
        contentView.addSubview(idLabel)
    }
    
    override func configureConstraints() {
        contentView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-2.5)
            make.top.equalToSuperview().offset(2.5)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        idLabel.snp.makeConstraints { make in
            make.top.equalTo(directionLabel.snp.bottom).offset(5)
            make.leading.equalTo(directionLabel.snp.leading)
            make.trailing.equalTo(directionLabel.snp.trailing)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.width.equalTo(amountLabel.snp.width)
            make.height.equalTo(amountLabel.snp.height)
            make.top.equalToSuperview().offset(15)
        }
        
        feeLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(5)
            make.trailing.equalTo(amountLabel.snp.trailing)
            make.width.equalTo(feeLabel.snp.width)
        }
        
        if let imageView = imageView {
            imageView.snp.makeConstraints { make in
                make.leading.equalTo(contentView.snp.leading)
                make.centerY.equalTo(contentView.snp.centerY)
                make.height.equalTo(imageView.snp.height)
                make.width.equalTo(imageView.snp.width)
            }
            
            dateLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(15)
                make.leading.equalTo(imageView.snp.trailing)
                make.height.equalTo(dateLabel.snp.height)
                make.width.equalTo(dateLabel.snp.width)
            }
            
            directionLabel.snp.makeConstraints { make in
                make.top.equalTo(dateLabel.snp.bottom).offset(5)
                make.leading.equalTo(imageView.snp.trailing)
                make.height.equalTo(directionLabel.snp.height)
                make.trailing.equalTo(amountLabel.snp.leading).offset(-10)
            }
        }
    }
    
    func configure(
        id: String,
        direction: TransactionDirection,
        formattedAmount: String,
        status: TransactionStatus,
        isPending: Bool,
        recipientAddress: String,
        date: Date,
        formattedFee: String) {
        setDirection(direction, isPendgin: isPending)
        setAmount(formattedAmount)
        setId(id)
        setDate(date)
        setFee(formattedFee)
        needsUpdateConstraints()
        layoutIfNeeded()
    }
    
    private func setDirection(_ direction: TransactionDirection, isPendgin: Bool) {
        var directionStr = ""
        
        switch direction {
        case .incoming:
            amountLabel.textColor = .lightGreen
            amountLabel.backgroundColor = UIColor.lightGreen.withAlphaComponent(0.15)
            directionStr = "Receive"
            feeLabel.isHidden = true
            imageView?.image = UIImage.fontAwesomeIcon(name: .longArrowUp, textColor: .lightGreen, size: TransactionUITableViewCell.imageSize)
        case .outgoing:
            amountLabel.textColor = .lightRed
            amountLabel.backgroundColor = UIColor.lightRed.withAlphaComponent(0.15)
            directionStr = "Sent"
            feeLabel.isHidden = false
            imageView?.image = UIImage.fontAwesomeIcon(name: .longArrowDown, textColor: .lightRed, size: TransactionUITableViewCell.imageSize)
        }
        
        if isPendgin {
            directionStr = "\(directionStr) (pending)"
            
            // FIX-ME: Unnamed constant
            
            contentView.backgroundColor = UIColor(hex: 0xF4FFFE)
        } else {
            contentView.backgroundColor = TransactionUITableViewCell.defaultContentBackgroundColor
        }
        
        directionLabel.text = directionStr
    }
    
    private func setAmount(_ amount: String) {
        amountLabel.text = amount
    }
    
    private func setFee(_ fee: String) {
        feeLabel.text = fee
    }
    
    private func setId(_ id: String) {
        idLabel.text = id
    }
    
    private func setDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateLabel.text = dateFormatter.string(from: date)
    }
}

