//
//  PrimaryButton.swift
//  Wallet
//
//  Created by FotoLockr on 27.09.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

final class PrimaryButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rounded()
    }
    
    override open var intrinsicContentSize: CGSize {
        let intrinsicContentSize = super.intrinsicContentSize
        let adjustedWidth = intrinsicContentSize.width + titleEdgeInsets.left + titleEdgeInsets.right
        let adjustedHeight = intrinsicContentSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom
        return CGSize(width: adjustedWidth, height: adjustedHeight)
    }
    
    override func configureView() {
        
        // FIX-ME: Unnamed constant
        
        backgroundColor = UIColor(hex: 0x8A4FFF)
        setTitleColor(.white, for: .normal)
//        layer.borderWidth = 1
//        layer.borderColor = UIColor.lightGray.cgColor
        layer.masksToBounds = false
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 2, height: 1)
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.lightGray.cgColor
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        contentHorizontalAlignment = .center
        titleLabel?.font = UIFont.avenirNextHeavy(size: 17)
    }
}
