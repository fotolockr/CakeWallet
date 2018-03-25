//
//  IconView.swift
//  CakeWallet
//
//  Created by Cake Technologies 26.01.2018.
//  Copyright © 2018 Cake Technologies. 
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
            textColor: .whiteSmoke,
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
        
        backgroundColor = .pictonBlue
        addSubview(imageView)
    }
    
    override func configureConstraints() {
        imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.top.equalToSuperview()
//            make.bottom.equalToSuperview()
            make.size.equalTo(imageSize)
        }
        
//        snp.makeConstraints { make in
//            make.size.equalTo(imageView.snp.size)
//        }
    }
}

extension IconView: Roundable {}

extension IconView {
    var isRoutating: Bool {
        return layer.animation(forKey: "rotation") != nil
    }
    
    func pulsate() {
        stopPulsate()
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
        stopRotate()
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
}
