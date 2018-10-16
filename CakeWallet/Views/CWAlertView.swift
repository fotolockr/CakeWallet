import UIKit
import FlexLayout

final class CWAlertView: BaseFlexView {
    private static let approximatedDefaultWidth = 325 as CGFloat
    let statusImageView: UIImageView
    let contentView: UIView
    let titleLabel: UILabel
    private(set) var messageLabel: UILabel?
    let actionsStackView: UIStackView
    let separatorView: UIView
    private(set) var activityIndicatorView: UIActivityIndicatorView?
    var width: CGFloat {
        return UIScreen.main.bounds.width > CWAlertView.approximatedDefaultWidth
            ? CWAlertView.approximatedDefaultWidth
            : UIScreen.main.bounds.width - 50 // 50 = 2x25 offset
    }
    
    required init() {
        titleLabel = UILabel(fontSize: 19)
        statusImageView = UIImageView(image: nil)
        contentView = UIView()
        actionsStackView = UIStackView(arrangedSubviews: [])
        separatorView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        isOpaque = true
        rootFlexContainer.backgroundColor = UIColor.whiteSmoke.withAlphaComponent(0.4)
        contentView.layer.masksToBounds = false
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor.blueBolt
        contentView.layer.shadowRadius = 20
        contentView.layer.shadowOffset = CGSize(width: 2, height: 1)
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowColor = UIColor.lightGray.cgColor
        //        actionsStackView.distribution = .fill
        //        actionsStackView.alignment = .fill
        separatorView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.frame.size.height * 0.1
    }
    
    override func configureConstraints() {
        contentView.flex.backgroundColor(.white).alignItems(.center).define { flex in
            flex.addItem(statusImageView).width(100).height(100).alignSelf(.center).position(.absolute).top(-30)
            
            if
                let messageLabel = self.messageLabel,
                let message = messageLabel.text,
                message.count > 0 {
                flex.addItem(titleLabel).margin(UIEdgeInsets(top: 80, left: 30, bottom: 20, right: 30))
                flex.addItem(messageLabel).margin(UIEdgeInsets(top: 0, left: 30, bottom: 30, right: 30))
            } else {
                flex.addItem(titleLabel).margin(UIEdgeInsets(top: 80, left: 30, bottom: 30, right: 30))
            }
            
            flex.addItem(separatorView).width(100%).height(1).backgroundColor(.lightBlueGrey)
            
            if let activityIndicatorView = activityIndicatorView {
                flex.addItem(activityIndicatorView).width(50).height(50)
            }
            
            flex.addItem(actionsStackView).width(100%).grow(1)
        }
        
        rootFlexContainer.flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(contentView).width(width).minHeight(50)
        }
    }
    
    func addMessageLabel() {
        guard messageLabel == nil else {
            return
        }
        
        messageLabel = UILabel(fontSize: 16)
        messageLabel?.textAlignment = .center
        messageLabel?.numberOfLines = 0
        messageLabel?.textColor = .wildDarkBlue
    }
    
    func addActivityIndicatorView() {
        guard activityIndicatorView == nil else {
            return
        }
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    }
}
