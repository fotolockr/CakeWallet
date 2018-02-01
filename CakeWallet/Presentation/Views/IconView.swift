//
//  IconView.swift
//  CakeWallet
//
//  Created by FotoLockr on 26.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
//

import UIKit
import FontAwesome_swift

final class IconView: UIView {
    private static let defaultImageSize = CGSize(width: 32, height: 32)
    let imageView: UIImageView
    private let imageSize: CGSize
    
    convenience init(fontAwesomeIcon: FontAwesome) {
        
        // FIX-ME: Unnamed constant
        
        self.init(iconImage: UIImage.fontAwesomeIcon(
            name: fontAwesomeIcon,
            textColor: UIColor(hex: 0xF5F7F9),
            size: IconView.defaultImageSize))
    }
    
    convenience init(iconImage: UIImage, imageSize: CGSize = IconView.defaultImageSize) {
        self.init(imageSize: imageSize)
        imageView.image = iconImage
    }
    
    init(imageSize: CGSize) {
        imageView = UIImageView()
        self.imageSize = imageSize
        super.init(frame: .zero)
        configureView()
        configureConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rounded()
    }
    
    override func configureView() {
        super.configureView()
        
        // FIX-ME: Unnamed constant
        
        backgroundColor = UIColor(hex: 0x2AB7CA) // UIColor(hex: 0x011627)
        addSubview(imageView)
    }
    
    override func configureConstraints() {
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(imageSize)
        }
    }
}

extension IconView: Roundable {}

extension IconView {
    var isRoutating: Bool {
        return layer.animation(forKey: "rotation") != nil
    }
    
    func pulsate() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 1.35
        pulse.fromValue = 0.85
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        //        pulse.initialVelocity = 0.5
        //        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
    func stopPulsate() {
        layer.removeAnimation(forKey: "pulse")
    }
    
    func rotate() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Double.pi
        rotationAnimation.duration = 1.0
        rotationAnimation.repeatCount = .infinity
        
        layer.add(rotationAnimation, forKey: "rotation")
    }
    
    func stopRotate() {
        layer.removeAnimation(forKey: "rotation")
    }
    
    func flash() {
        let flash = CABasicAnimation(keyPath: "opacity")
        flash.duration = 0.2
        flash.fromValue = 1
        flash.toValue = 0.1
        flash.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        flash.autoreverses = true
        flash.repeatCount = 3
        
        layer.add(flash, forKey: nil)
    }
    
    
    func shake() {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.05
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: center.x - 5, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: center.x + 5, y: center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        
        layer.add(shake, forKey: "position")
    }
}
