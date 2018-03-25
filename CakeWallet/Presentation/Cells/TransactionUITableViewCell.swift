//
//  TransactionUITableViewCell.swift
//  Wallet
//
//  Created by Cake Technologies 11/27/17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit
import FontAwesome_swift

final class TransactionUITableViewCell: UITableViewCell {
    static private let defaultContentBackgroundColor = UIColor.white
    static private let imageSize = CGSize(width: 26, height: 26)
    let directionLabel: UILabel
    let amountLabel: UILabel
    let dateLabel: UILabel

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        directionLabel = UILabel(font: .avenirNextMedium(size: 15))
        amountLabel = PaddingLabel(
            insets: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10),
            font: .avenirNextDemiBold(size: 15))
        dateLabel = UILabel(font: .avenirNextMedium(size: 14))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        dateLabel.textColor = .gray
        
        // FIX-ME: Unnamed constant
        
        directionLabel.textColor = UIColor(hex: 0x303030)
        amountLabel.layer.masksToBounds = true
        amountLabel.layer.cornerRadius = 10
        amountLabel.textAlignment = .right
        backgroundColor = .clear
        contentView.backgroundColor = .white
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 5
        contentView.addSubview(dateLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(directionLabel)
    }
    
    override func configureConstraints() {
        contentView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-5.5)
            make.top.equalToSuperview().offset(5.5)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        amountLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-15)
            make.leading.equalTo(directionLabel.snp.trailing)
            make.height.equalTo(amountLabel.snp.height)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        
        if let imageView = imageView {
            imageView.snp.makeConstraints { make in
                make.leading.equalTo(contentView.snp.leading)
                make.centerY.equalTo(contentView.snp.centerY)
                make.height.equalTo(TransactionUITableViewCell.imageSize.height)
                make.width.equalTo(TransactionUITableViewCell.imageSize.width)
            }
            
            dateLabel.snp.makeConstraints { make in
                make.centerY.equalTo(contentView.snp.centerY)
                make.leading.equalTo(imageView.snp.trailing)
                make.height.equalTo(dateLabel.snp.height)
                make.width.equalTo(40)
            }
            
            directionLabel.snp.makeConstraints { make in
                make.centerY.equalTo(contentView.snp.centerY)
                make.leading.equalTo(dateLabel.snp.trailing)
                make.height.equalTo(directionLabel.snp.height)
                make.trailing.equalTo(amountLabel.snp.leading).offset(-10)
            }
        }
    }
    
    func configure(
        direction: TransactionDirection,
        formattedAmount: String,
        status: TransactionStatus,
        isPending: Bool,
        recipientAddress: String,
        date: Date) {
        setDirection(direction, isPendgin: isPending)
        setAmount(formattedAmount)
        setDate(date)
        needsUpdateConstraints()
        layoutIfNeeded()
    }
    
    func short() {
        imageView?.image = nil
        dateLabel.text = nil
        dateLabel.isHidden = true
        directionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        needsUpdateConstraints()
        layoutIfNeeded()
    }
    
    private func setDirection(_ direction: TransactionDirection, isPendgin: Bool) {
        var directionStr = ""
        
        switch direction {
        case .incoming:
            amountLabel.textColor = .lightGreen
            directionStr = "Received"
            imageView?.image = UIImage.fontAwesomeIcon(name: .longArrowUp, textColor: .lightGreen, size: TransactionUITableViewCell.imageSize)
        case .outgoing:
            amountLabel.textColor = .lightRed
            directionStr = "Sent"
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
    
    
    private func setDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateLabel.text = dateFormatter.string(from: date)
    }
}

