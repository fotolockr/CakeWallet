import UIKit

class LoadingButton: UIButton {
    var originalButtonText: String?
    var activityIndicator: UIActivityIndicatorView?
    
    required init() {
        super.init(frame: .zero)
        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
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
        layer.cornerRadius = 10
        layer.masksToBounds = false
        layer.shadowRadius = 20
        layer.shadowOffset = CGSize(width: 2, height: 1)
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.borderWidth = 0.75
        layer.borderColor = UIColor.purpleyBorder.cgColor
        contentHorizontalAlignment = .center
        titleLabel?.font = applyFont(ofSize: 17)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }
}

final class PrimaryLoadingButton: LoadingButton {
    override func configureView() {
        super.configureView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
