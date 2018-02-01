//
//  PinPasswordViewController.swift
//  Wallet
//
//  Created by FotoLockr on 02.10.17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

protocol PinPasswordViewOutput {
    typealias OnPinReady = (String) -> Void
    func pin(_ callback: @escaping OnPinReady)
}

final class PinPasswordViewController: BaseViewController<PinPasswordView>, PinPasswordViewOutput {
    var descriptionText: String {
        get { return contentView.descriptionLabel.text ?? "" }
        set {
            guard canSetDescription else {
                return
            }
            contentView.descriptionLabel.text = newValue
        }
    }
    private var canSetDescription: Bool
    var onCloseHandler: VoidEmptyHandler
    private var callback: OnPinReady?
    private var pin: [Int]
    
    override init() {
        pin = []
        canSetDescription = true
        super.init()
        descriptionText = "Enter your pin"
        configureKeyboardPin()
    }

    convenience init(canClose: Bool) {
        self.init()

        if canClose {
            contentView.addCloseButton()
            contentView.closeButton?.addTarget(self, action: #selector(onClose), for: .touchUpInside)
        }
    }
    
    func pin(_ callback: @escaping OnPinReady) {
        self.callback = callback
    }
    
    func empty() {
        pin = []
        contentView.stackView.arrangedSubviews.forEach {
            if let pinView = $0 as? PinView {
                pinView.clear()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        UserDefaults.standard.rx.observe(TimeInterval.self, "unban_time")
//            .map({ time -> TimeInterval in
//                if let time = time {
//                    return time
//                }
//
//                return 0
//            }).subscribe(onNext: { banTime in
//                self.set(banTime: banTime)
//            }).disposed(by: disposeBag)
    }
    
    @objc
    private func onClose() {
        if presentingViewController != nil {
            dismiss(animated: true) { [weak self] in
                self?.onCloseHandler?()
            }
        } else {
            onCloseHandler?()
        }
    }
    
    private func set(banTime: TimeInterval) {
        let baseStr = "Try enter pin after: "
        let time = banTime - Date().timeIntervalSince1970

        if time > 0 {
            descriptionText = baseStr + time.stringTime
            canSetDescription = false
        } else {
            canSetDescription = true
            contentView.descriptionLabel.text = descriptionText
        }
    }
    
    private func configureKeyboardPin() {
        contentView.keyboard.add { key in
            switch key {
            case .number(let number):
                self.addPin(number)
            case .delete:
                self.deleteLast()
            }
        }
    }
    
    private func addPin(_ number: Int) {
        guard pin.count < 4 else {
            return
        }
        
        pin.append(number)
        let index = pin.endIndex - 1
        
        guard let pinView = contentView.stackView.arrangedSubviews[index] as? PinView else {
            return
        }
        
        pinView.fill()
        
        if (pin.count == 4) {
            let pinStr = pin.map({"\($0)"}).joined()
            callback?(pinStr)
        }
    }
    
    private func deleteLast() {
        let index = pin.endIndex - 1
        
        guard
            index >= 0,
            let pinView = contentView.stackView.arrangedSubviews[index] as? PinView else {
                return
        }
        
        pinView.clear()
        _ = pin.popLast()
    }
}


extension TimeInterval {
    private var milliseconds: Int {
        return Int((truncatingRemainder(dividingBy: 1)) * 1000)
    }
    
    private var seconds: Int {
        return Int(self) % 60
    }
    
    private var minutes: Int {
        return (Int(self) / 60 ) % 60
    }
    
    private var hours: Int {
        return Int(self) / 3600
    }
    
    var stringTime: String {
        if hours != 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes != 0 {
            return "\(minutes)m \(seconds)s"
        } else if milliseconds != 0 {
            return "\(seconds)s \(milliseconds)ms"
        } else {
            return "\(seconds)s"
        }
    }
}
