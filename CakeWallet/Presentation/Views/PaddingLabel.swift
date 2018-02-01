//
//  PaddingLabel.swift
//  Wallet
//
//  Created by FotoLockr on 17.10.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

final class PaddingLabel: UILabel {
    let insets: UIEdgeInsets
    
    init(insets: UIEdgeInsets, font: UIFont = UIFont.avenirNext(size: 17)) {
        self.insets = insets
        super.init(frame: .zero)
        self.font =  font
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = UIEdgeInsetsInsetRect(bounds, insets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -insets.top,
                                          left: -insets.left,
                                          bottom: -insets.bottom,
                                          right: -insets.right)
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
