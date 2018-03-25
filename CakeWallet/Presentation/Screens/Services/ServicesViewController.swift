//
//  ServicesViewController.swift
//  CakeWallet
//
//  Created by Cake Technologies on 15.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit
import FontAwesome_swift

final class ServicesViewController: BaseViewController<ServicesView> {
    private let exchangeViewController: ExchangeViewController
    private let buyViewController: BuyViewController
    private var currentIndex = 0
    
    init(exchangeViewController: ExchangeViewController, buyViewController: BuyViewController) {
        self.exchangeViewController = exchangeViewController
        self.buyViewController = buyViewController
        super.init()
    }
    
    override func configureDescription() {
        title = "Services"
        updateTabBarIcon(name: .thLarge)
    }
    
    override func configureBinds() {
        super.configureBinds()
        contentView.segmentedControl.addTarget(self, action: #selector(onSegmentChange(_:)), for: .valueChanged)
        contentView.segmentedControl.selectedSegmentIndex = 0
        presentExchange()
        
        contentView.innerView.addSubview(exchangeViewController.view)
        exchangeViewController.view.snp.makeConstraints({ make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        })
        
        contentView.innerView.addSubview(buyViewController.view)
        buyViewController.view.snp.makeConstraints({ make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        })
    }
    
    @objc
    private func onSegmentChange(_ sender: UISegmentedControl) {
        guard sender.selectedSegmentIndex != currentIndex && sender.selectedSegmentIndex == 0 else {
            sender.selectedSegmentIndex = 0
            UIAlertController.showInfo(message: "Coming soon", presentOn: self)
            return
        }
        
        currentIndex = sender.selectedSegmentIndex
        switch sender.selectedSegmentIndex {
        case 0:
            presentExchange()
        case 1:
            presentBuy()
        default:
            break
        }
    }
    
    private func presentExchange() {
        exchangeViewController.view.isHidden = false
        buyViewController.view.isHidden = true
    }
    
    private func presentBuy() {
        exchangeViewController.view.isHidden = true
        buyViewController.view.isHidden = false
    }
}
