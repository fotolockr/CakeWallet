//
//  ConnectionSettings+CellItem.swift
//  CakeWallet
//
//  Created by Cake Technologies on 07.04.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import UIKit

extension ConnectionSettings: CellItem {
    func setup(cell: NodeUITableViewCell) {
        cell.configure(uri: uri)
        
        connect()
            .then(on: DispatchQueue.main) { (canConnect, _) -> Void in
                cell.statusImageView.image = UIImage.fontAwesomeIcon(
                    name: .circle,
                    textColor: canConnect ? UIColor.green : UIColor.red,
                    size: CGSize(width: 16, height: 16))
            }.catch { _ in
                cell.statusImageView.image = UIImage.fontAwesomeIcon(
                    name: .circle,
                    textColor: UIColor.red,
                    size: CGSize(width: 16, height: 16))
        }
    }
}
