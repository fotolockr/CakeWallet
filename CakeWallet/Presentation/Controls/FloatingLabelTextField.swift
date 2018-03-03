//
//  FloatingLabelTextField.swift
//  CakeWallet
//
//  Created by Cake Technologies on 22.02.2018.
//  Copyright © 2018 Cake Technologies. All rights reserved.
//

import Foundation
import SkyFloatingLabelTextField

final class FloatingLabelTextField: SkyFloatingLabelTextField {
    convenience init(placeholder: String) {
        self.init(placeholder: placeholder, title: placeholder)
    }
    
    init(placeholder: String, title: String) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        self.title = title
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
