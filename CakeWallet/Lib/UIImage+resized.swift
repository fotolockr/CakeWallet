//
//  UIImage+resized.swift
//  CakeWallet
//
//  Created by Cake Technologies on 06.03.2018.
//  Copyright © 2018 Cake Technologies. 
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
