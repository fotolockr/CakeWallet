//
//  BaseView.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit

extension UIView {
    @objc
    func configureView() {}
    @objc
    func configureConstraints() {}
}

class BaseView: UIView {
    var titleView: (TitledView & UIView)? {
        willSet {
            guard newValue != nil else {
                return
            }
            
            titleView?.removeFromSuperview()
        }
        
        didSet {
            guard let view = titleView else {
                return
            }
            
            addSubview(view)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init() {
        super.init(frame: CGRect.zero)
        configureView()
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configureConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func configureView() {
        super.configureView()
        
        // FIX-ME: Unnamed constant
        
        backgroundColor = .white //UIColor(hex: 0xFCFCFC)
    }
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
            break
        default:
            break
        }
        
        
        border.backgroundColor = color.cgColor
        
        self.addSublayer(border)
    }
}

extension BaseView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        return false
    }
}

extension BaseView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }
}


