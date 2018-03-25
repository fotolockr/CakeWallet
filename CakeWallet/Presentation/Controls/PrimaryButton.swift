//
//  PrimaryButton.swift
//  Wallet
//
//  Created by Cake Technologies 27.09.17.
//  Copyright © 2017 Cake Technologies. 
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
        
        backgroundColor = .pictonBlue
        setTitleColor(.white, for: .normal)
        layer.masksToBounds = false
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 2, height: 1)
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.lightGray.cgColor
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        contentHorizontalAlignment = .center
        titleLabel?.font = UIFont.avenirNextHeavy(size: 17)
    }
}
