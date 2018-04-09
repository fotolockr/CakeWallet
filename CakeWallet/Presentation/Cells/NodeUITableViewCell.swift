//
//  NodeUITableViewCell.swift
//  CakeWallet
//
//  Created by Cake Technologies on 07.04.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit

final class NodeUITableViewCell: UITableViewCell {
    let statusImageView: UIImageView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        statusImageView = UIImageView(image: UIImage.fontAwesomeIcon(name: .circle, textColor: .clear, size: CGSize(width: 16, height: 16)))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        super.configureView()
        textLabel?.font = UIFont.avenirNextMedium(size: 15)
        textLabel?.backgroundColor = .clear
        accessoryView  = statusImageView
    }
    
    func configure(uri: String) {
        textLabel?.text = uri
    }
    
    func setConnection(status: Bool) {
        if status {
            statusImageView.image = UIImage.fontAwesomeIcon(name: .circle, textColor: .green, size: CGSize(width: 16, height: 16))
        } else {
            statusImageView.image = UIImage.fontAwesomeIcon(name: .circle, textColor: .red, size: CGSize(width: 16, height: 16))
        }
        
        statusImageView.backgroundColor = .clear
    }
}

