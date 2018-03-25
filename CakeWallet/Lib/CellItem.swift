//
//  CellItem.swift
//  Wallet
//
//  Created by Cake Technologies 18.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit

protocol CellAnyItem {
    static var cellAnyType: UIView.Type { get }
    func setupAny(cell: UIView)
}

protocol CellItem: CellAnyItem {
    associatedtype CellType: UIView
    func setup(cell: CellType)
}

extension CellItem {
    static var cellAnyType: UIView.Type {
        return CellType.self
    }
    
    func setupAny(cell: UIView) {
        if let cell = cell as? CellType {
            setup(cell: cell)
        } else {
            assertionFailure("Cannot cast cell type. Incorrect cell type.")
        }
    }
}
