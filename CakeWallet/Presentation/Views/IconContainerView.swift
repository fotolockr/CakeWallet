//
//  IconContainerView.swift
//  CakeWallet
//
//  Created by Cake Technologies 26.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit
import FontAwesome_swift

final class IconContainerView<ContentViewType: UIView>: UIView {
    let contentView: ContentViewType
    let iconView: IconView
    
    convenience init(contentView: ContentViewType, fontAwesomeIcon: FontAwesome) {
        let iconView = IconView(fontAwesomeIcon: fontAwesomeIcon)
        self.init(contentView: contentView, iconView: iconView)
    }
    
    init(contentView: ContentViewType, iconView: IconView) {
        self.contentView = contentView
        self.iconView = iconView
        super.init(frame: .zero)
        configureView()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        addSubview(iconView)
        addSubview(contentView)
    }
    
    override func configureConstraints() {
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview()
//            make.width.equalTo(iconView.imageView.snp.width)
//            make.height.equalTo(iconView.imageView.snp.width)
            make.width.equalTo(42)
            make.height.equalTo(42)
        }
        
        contentView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.leading.equalTo(iconView.snp.trailing).offset(10)
            make.top.equalTo(iconView.snp.top)
            make.bottom.equalToSuperview()
        }
    }
}
