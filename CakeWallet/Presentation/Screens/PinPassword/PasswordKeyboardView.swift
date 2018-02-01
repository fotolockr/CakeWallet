//
//  PasswordKeyboardView.swift
//  Wallet
//
//  Created by FotoLockr on 02.10.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit
import SnapKit
import FontAwesome_swift

// FIX-ME: Replace it.

fileprivate let totalButtonsCount = 13
fileprivate let zeroButtonPosition = 11
fileprivate let deleteButtonPosition = 12
fileprivate let numbersLastButtonPosition = 10
fileprivate let itemsInRow = 3
fileprivate let numberOfRows = totalButtonsCount / 3
fileprivate let keyFontSize: CGFloat = 24

// FIX-ME: Replace it.

fileprivate let textFieldHeight = 50

final class PasswordKeyboardView: UIView {
    typealias OnKeyPressCallback = (PasswordKeyboardKey) -> ()
    private var callback: OnKeyPressCallback?
    
    required init() {
        self.callback = nil
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        drawKeyboardKeys()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("DEINIT PasswordKeyboardView")
    }
    
    private func drawKeyboardKeys() {
        var previousButtonWrapper: UIView? = nil
        var isNewRow = true
        
        for i in 1..<totalButtonsCount {
            let buttonWrapperView = UIView()
            let button = PinKeyButton(title: "")
            buttonWrapperView.addSubview(button)
            addSubview(buttonWrapperView)
            
            if i < numbersLastButtonPosition {
                button.setTitle("\(i)", for: .normal)
            } else if i == zeroButtonPosition {
                button.setTitle("0", for: .normal)
            } else if i == deleteButtonPosition {
                button.titleLabel?.font = UIFont.fontAwesome(ofSize: keyFontSize)
                button.setTitle(String.fontAwesomeIcon(name: .longArrowLeft), for: .normal)
                button.tag = deleteButtonPosition
            }
            
            if i != numbersLastButtonPosition {
                button.addTarget(self, action: #selector(keyPressed(_:)), for: .touchUpInside)
            }
            
            button.snp.makeConstraints{ make in
                make.center.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.9)
                make.width.equalTo(button.snp.height)
            }
            
            buttonWrapperView.snp.makeConstraints({ make in
                make.width.equalToSuperview().multipliedBy(0.3334)
                make.height.equalToSuperview().dividedBy(numberOfRows)
                
                if let previousButton = previousButtonWrapper,
                    !isNewRow {
                    make.leading.equalTo(previousButton.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
                
                let top = isNewRow ? previousButtonWrapper?.snp.bottom : previousButtonWrapper?.snp.top
                
                if let top = top {
                    make.top.equalTo(top)
                } else {
                    make.top.equalToSuperview()
                }
            })
            
            if i % itemsInRow == 0 {
                isNewRow = true
            } else if isNewRow == true {
                isNewRow = false
            }
            
            previousButtonWrapper = buttonWrapperView
        }
    }
    
    @objc
    private func keyPressed(_ button: UIButton) {
        let str = button.tag == deleteButtonPosition ? "Del" : (button.titleLabel?.text ?? "")
        
        guard let key = PasswordKeyboardKey(from: str) else {
            return
        }
        
        self.onKeyPressed(key: key)
    }
    
    private func onKeyPressed(key: PasswordKeyboardKey) {
       callback?(key)
    }
    
    func add(action: @escaping OnKeyPressCallback) {
        callback = action
    }
}
