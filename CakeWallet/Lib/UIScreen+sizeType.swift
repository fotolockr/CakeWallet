//
//  UIScreen+sizeType.swift
//  CakeWallet
//
//  Created by Cake Technologies on 24.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

extension UIScreen {
    enum SizeType: CGFloat {
        case Unknown = 0.0
        case iPhone4 = 960.0
        case iPhone5 = 1136.0
        case iPhone6 = 1334.0
        case iPhone6Plus = 1920.0
    }
    
    var sizeType: SizeType {
        let height = nativeBounds.height
        guard let sizeType = SizeType(rawValue: height) else { return .Unknown }
        return sizeType
    }
}
