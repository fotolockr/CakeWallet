//
//  ServicesView.swift
//  CakeWallet
//
//  Created by Cake Technologies on 15.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class ServicesView: BaseView {
    let segmentedControl: UISegmentedControl
    var innerView: UIView
    
    required init() {
        segmentedControl = UISegmentedControl(items: ["Exchange", "Redeem"])
        innerView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        backgroundColor = .whiteSmoke
        addSubview(segmentedControl)
        addSubview(innerView)
    }
    
    override func configureConstraints() {
        segmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        
        innerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
        }
    }
}
