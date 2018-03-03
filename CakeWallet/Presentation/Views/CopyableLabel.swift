//
//  CopyableLabel.swift
//  CakeWallet
//
//  Created by Cake Technologies on 02.03.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit

final class CopyableLabel: UILabel {
    override public var canBecomeFirstResponder: Bool {
        get { return _canBecomeFirstResponder }
    }
    
    private var _canBecomeFirstResponder: Bool
    
    override init(frame: CGRect) {
        _canBecomeFirstResponder = true
        super.init(frame: frame)
        isUserInteractionEnabled = true
        addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showContextMenu(sender:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(copy(_:)))
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
    
    @objc
    private func showContextMenu(sender: Any?) {
        becomeFirstResponder()
        let menuController = UIMenuController.shared
        if !menuController.isMenuVisible {
            menuController.setTargetRect(bounds, in: self)
            menuController.setMenuVisible(true, animated: true)
        }
    }
}
