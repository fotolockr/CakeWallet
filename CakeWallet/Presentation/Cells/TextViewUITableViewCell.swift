//
//  TextViewUITableViewCell.swift
//  CakeWallet
//
//  Created by Cake Technologies on 28.03.2018.
//  Copyright © 2018  Cake Technologies.
//

import UIKit

final class TextViewUITableViewCell: UITableViewCell {
    let textView: UITextView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        textView = UITextView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        textView.isEditable = false
        contentView.addSubview(textView)
        accessoryType = .none
    }
    
    override func configureConstraints() {
        textView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func configure(attributedText: NSAttributedString) {
        textView.attributedText = attributedText
    }
}
