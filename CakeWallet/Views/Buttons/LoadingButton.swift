import UIKit

class LoadingButton: UIButton {
    var originalButtonText: String?
    var activityIndicator: UIActivityIndicatorView?
        
    func showLoading() {
        originalButtonText = self.titleLabel?.text
        setTitle("", for: .normal)
        activityIndicator = createActivityIndicator()
        
        if let activityIndicator = activityIndicator {
            addSubview(activityIndicator)
        }
        
        isEnabled = false
        activityIndicator?.startAnimating()
    }
    
    func hideLoading() {
        isEnabled = true
        setTitle(originalButtonText, for: .normal)
        activityIndicator?.stopAnimating()
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let size = CGSize(width: 25, height: 25)
        let y = frame.size.height / 2 - size.height / 2
        let x = frame.size.width / 2 - size.width / 2
        let indicator = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: x, y: y), size: size))
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }
    
    override func configureView() {
        super.configureView()
        
        backgroundColor = Theme.current.primaryButton.background
        setTitleColor(Theme.current.primaryButton.text, for: .normal)
        layer.masksToBounds = false
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 2, height: 1)
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.lightGray.cgColor
        contentHorizontalAlignment = .center
        titleLabel?.font = applyFont(weight: .semibold)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }
}

final class PrimaryLoadingButton: LoadingButton {
    override func configureView() {
        super.configureView()        
        layer.applySketchShadow(color: UIColor(hex: 0xdfd0ff), alpha: 0.34, x: 0, y: 5, blur: 10, spread: -10)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyGradient(colours: [UIColor(red: 126, green: 92, blue: 250), UIColor(red: 126, green: 92, blue: 250)])
    }
}
