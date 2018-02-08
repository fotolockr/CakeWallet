//
//  UICollectionView+CellItem.swift
//  Wallet
//
//  Created by Cake Technologies 18.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit

extension UITableView {
    func register(items: [CellAnyItem.Type]) {
        for item in items {
            let identifier = String(describing: item.cellAnyType)
            self.register(item.cellAnyType, forCellReuseIdentifier: identifier)
        }
    }
    
    func dequeueReusableCell(withItem item: CellAnyItem, for indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: type(of: item).cellAnyType)
        let cell = self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        item.setupAny(cell: cell)
        return cell
    }
}
