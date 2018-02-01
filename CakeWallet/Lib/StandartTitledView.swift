//
//  DefaultTitledView.swift
//  Wallet
//
//  Created by FotoLockr on 12/10/17.
//  Copyright © 2017 FotoLockr. All rights reserved.
//

import UIKit

final class StandartTitledView: UIView {
    let titleLabel: UILabel
    let subtitleLabel: UILabel
    
    init() {
        titleLabel = UILabel(font: .avenirNextMedium(size: 32))
        subtitleLabel = UILabel(font: .avenirNextMedium(size: 14))
        super.init(frame: .zero)
        configureView()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        subtitleLabel.textColor = .lightGray
        addSubview(titleLabel)
        addSubview(subtitleLabel)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        configureConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom)
            make.leading.equalTo(subtitleLabel.snp.leading)
            make.trailing.equalToSuperview()
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        self.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
}

extension StandartTitledView: TitledView {
    var title: String {
        get { return titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }
    
    var subtitle: String {
        get { return subtitleLabel.text ?? "" }
        set { subtitleLabel.text = newValue }
    }
}
