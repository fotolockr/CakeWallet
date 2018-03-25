//
//  PinKeyButton.swift
//  Wallet
//
//  Created by Cake Technologies 11/17/17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

final class PinKeyButton: UIButton {
    override var isHighlighted: Bool {
        set { }
        get { return super.isHighlighted }
    }
    
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
        addShadowView()
    }
    
    override func configureView() {
        showsTouchWhenHighlighted = false
        contentHorizontalAlignment = .center
        titleLabel?.font = UIFont.avenirNextMedium(size: 24)
        setTitleColor(.lightGray, for: .normal)
        backgroundColor = .white
    }
}
