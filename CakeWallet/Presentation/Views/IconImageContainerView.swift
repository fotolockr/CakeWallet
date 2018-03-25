//
//  IconImageContainerView.swift
//  CakeWallet
//
//  Created by Cake Technologies on 06.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

final class IconImageContainerView<ContentViewType: UIView>: UIView {
    let contentView: ContentViewType
    let imageView: UIImageView
    
    init(contentView: ContentViewType, iconImage: UIImage) {
        self.contentView = contentView
        self.imageView = UIImageView(image: iconImage)
        super.init(frame: .zero)
        configureView()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        addSubview(imageView)
        addSubview(contentView)
    }
    
    override func configureConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview()
            make.width.equalTo(42)
            make.height.equalTo(42)
        }
        
        contentView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.top.equalTo(imageView.snp.top)
            make.bottom.equalToSuperview()
        }
    }
}

