import UIKit

final class CWAlertViewController: BaseViewController<CWAlertView> {
    enum Status {
        case info, success, error, spinner
        
        var image: UIImage {
            switch self {
            case .info:
                return UIImage(named: "info-icon")!
            case .error:
                return UIImage(named: "info-icon")!
            case .success:
                return UIImage(named: "success-icon")!
            case .spinner:
                return UIImage(named: "info-icon")!
            }
        }
    }
    
    let status: Status
    let message: String?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .`default`
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    init(title: String?, message: String? = nil, status: Status) {
        self.message = message
        self.status = status
        super.init()
        self.title = title
    }
    
    override func configureBinds() {
        super.configureBinds()
        modalPresentationStyle = .overFullScreen
        contentView.statusImageView.image = status.image
        contentView.titleLabel.text = title
        contentView.titleLabel.flex.markDirty()
        
        if let message = self.message {
            addMessage(message)
        }
        
        if status == .spinner {
            addSpinner()
        }
        contentView.rootFlexContainer.flex.layout()
    }
    
    func addActions(_ actions: [CWAlertAction]) {
        guard actions.count > 0 && status != .spinner else {
            return
        }
        
        let sortedActions = actions.sorted { a, _ in
            return a.style == .cancel
        }
        
        for (index, action) in sortedActions.enumerated() {
            let width: CGFloat
            
            if actions.count != 2 {
                width = contentView.width
            } else {
                width = contentView.width > 0 ? (contentView.width / 2) - 1 : contentView.width
            }
            
            //            action.frame = CGRect(origin: .zero, size: CGSize(width: width, height: CWAlertAction.defaultHeight))
            action.widthAnchor.constraint(equalToConstant: width).isActive = true
            action.alertView = self
            action.backgroundColor = .clear
            contentView.actionsStackView.addArrangedSubview(action)
            
            if sortedActions.count == 2 && index == 0 {
                let separatorView = UIView()
                separatorView.backgroundColor = .lightBlueGrey
                separatorView.widthAnchor.constraint(equalToConstant: 1).isActive = true
                contentView.actionsStackView.addArrangedSubview(separatorView)
            }
        }
        
        contentView.actionsStackView.axis = sortedActions.count > 2 ? .vertical : .horizontal
        let actionsStackViewHeight = sortedActions.count > 2 ? CWAlertAction.defaultHeight * CGFloat(sortedActions.count) : CWAlertAction.defaultHeight
        contentView.actionsStackView.flex.height(actionsStackViewHeight).markDirty()
        contentView.separatorView.isHidden = false
        contentView.rootFlexContainer.flex.layout()
    }
    
    func addMessage(_ message: String) {
        let messageLabel: UILabel
        
        if contentView.messageLabel == nil {
            contentView.addMessageLabel()
        }
        
        messageLabel = contentView.messageLabel!
        messageLabel.text = message
        messageLabel.flex.markDirty()
        contentView.rootFlexContainer.setNeedsLayout()
    }
    
    func addSpinner() {
        contentView.addActivityIndicatorView()
        contentView.actionsStackView.arrangedSubviews.forEach {
            contentView.actionsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        contentView.actionsStackView.flex.height(nil).markDirty()
        contentView.separatorView.isHidden = false
        contentView.actionsStackView.flex.markDirty()
        contentView.rootFlexContainer.setNeedsLayout()
        contentView.activityIndicatorView?.startAnimating()
    }
}
