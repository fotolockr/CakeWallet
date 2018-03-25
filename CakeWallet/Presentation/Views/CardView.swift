//
//  CardView.swift
//  CakeWallet
//
//  Created by Cake Technologies on 09.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class CardView: BaseView {
    override func configureView() {
        super.configureView()
        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 10
    }
}
