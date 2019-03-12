import UIKit

final class PinCodeKeyButton: UIButton {
    override var isHighlighted: Bool {
        set { }
        get { return super.isHighlighted }
    }
    var pinCode: PinCodeKeyboardKey
    
    init(pinCode: PinCodeKeyboardKey) {
        self.pinCode = pinCode
        super.init(frame: .zero)
        
        if .del == pinCode {
            setImage(UIImage(named: "delete_icon"), for: .normal)
        } else {
            setTitle(pinCode.string(), for: .normal)
        }
        
        configureView()
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureView() {
        showsTouchWhenHighlighted = false
        contentHorizontalAlignment = .center
        setTitleColor(.white, for: .normal)
        titleLabel?.font = applyFont(ofSize: 26, weight: .regular)
        
        
        backgroundColor = Theme.current.pinKey.background
        layer.applySketchShadow(color: UIColor(hex: 0x9BACC5), alpha: 0.45, x: 0, y: 19, blur: 22, spread: -11)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        layer.cornerRadius = frame.size.width * 0.4
    }
}
