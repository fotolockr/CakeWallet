import UIKit

extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
}

final class PrimaryButton: Button {
    override func configureView() {
        super.configureView()
//        self.applyGradient(colours: [UIColor.yellow, UIColor.blue])
        
        layer.applySketchShadow(color: UIColor(hex: 0x298aff), alpha: 0.34, x: 0, y: 10, blur: 20, spread: -10)
    }
}
