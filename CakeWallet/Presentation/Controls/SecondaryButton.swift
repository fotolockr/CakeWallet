//
//  SecondaryButton.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

final class SecondaryButton: UIButton {
    init(image: UIImage) {
        super.init(frame: .zero)
        setImage(image, for: .normal)
        configureView()
    }
    
    init(title: String) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var intrinsicContentSize: CGSize {
        let intrinsicContentSize = super.intrinsicContentSize
        let adjustedWidth = intrinsicContentSize.width + titleEdgeInsets.left + titleEdgeInsets.right
        let adjustedHeight = intrinsicContentSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom
        return CGSize(width: adjustedWidth, height: adjustedHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rounded()
    }
    
    override func configureView() {
        
        // FIX-ME: Unnamed constant
        
        backgroundColor = UIColor(hex: 0xE5ECF4)
        setTitleColor(.gray, for: .normal)
//        layer.borderWidth = 1
//        layer.borderColor = UIColor.gray.cgColor
        layer.masksToBounds = true
        layer.cornerRadius = 10
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        contentHorizontalAlignment = .center
        titleLabel?.font = UIFont.avenirNextHeavy(size: 14)
        titleLabel?.numberOfLines = 0
//        semanticContentAttribute = .forceRightToLeft
    }
    
    func setLeftImage(_ image: UIImage) {
        setImage(image, for: .normal)
        contentHorizontalAlignment = .left
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width + 10)
        layoutSubviews()
    }
}
