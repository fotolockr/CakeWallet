import UIKit
import FlexLayout

final class CWAlertView: CWBaseAlertView {
    private(set) var innerView: UIView?
    var messageLabel: UILabel? {
        return innerView as? UILabel
    }
    let actionsStackView: UIStackView
    let separatorView: UIView
    private(set) var activityIndicatorView: UIActivityIndicatorView?

    required init() {
        actionsStackView = UIStackView(arrangedSubviews: [])
        separatorView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
//        isOpaque = true
//        rootFlexContainer.backgroundColor = UIColor.whiteSmoke.withAlphaComponent(0.4)
//        contentView.layer.masksToBounds = false
//        titleLabel.textAlignment = .center
//        titleLabel.numberOfLines = 0
//        titleLabel.textColor = UIColor.blueBolt
//        contentView.layer.shadowRadius = 20
//        contentView.layer.shadowOffset = CGSize(width: 2, height: 1)
//        contentView.layer.shadowOpacity = 0.3
//        contentView.layer.shadowColor = UIColor.lightGray.cgColor
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
            
            if let innerView = self.innerView {
                flex.addItem(titleLabel).margin(UIEdgeInsets(top: 80, left: 30, bottom: 20, right: 30))
                flex.addItem(innerView)
            }
            
            flex.addItem(separatorView).width(100%).height(1).backgroundColor(.lightBlueGrey)
            
            if let activityIndicatorView = activityIndicatorView {
                flex.addItem(activityIndicatorView).width(50).height(50)
            }
            
            flex.addItem(actionsStackView).width(100%).grow(1)
        }
        
        super.configureConstraints()
    }
    
    func setInnerView(_ view: UIView) {
        innerView = view
    }
    
    func addMessageLabel() {
        guard messageLabel == nil else {
            return
        }
        
        innerView = UILabel(fontSize: 16)
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

final class ExchangeAlertViewController: BaseViewController<ExchangeAlertView> {
    var onDone: (() -> Void)?
    
    override func configureBinds() {
        super.configureBinds()
        modalPresentationStyle = .overFullScreen
        contentView.statusImageView.image = UIImage(named: "info-icon")
        contentView.titleLabel.text = title
        contentView.titleLabel.flex.markDirty()
        contentView.innerView.flex.markDirty()
        contentView.flex.markDirty()
        contentView.rootFlexContainer.setNeedsLayout()
        contentView.rootFlexContainer.flex.layout()
        contentView.doneButton.addTarget(self, action: #selector(_onDone), for: .touchUpInside)
        contentView.cancelButton.addTarget(self, action: #selector(_onCancel), for: .touchUpInside)
    }
    
    func setTradeID(_ id: String) {
        contentView.innerView.setTradeID(id)
    }
    
    @objc
    private func _onDone() {
        dismiss(animated: true) {
            self.onDone?()
        }
    }

    @objc
    private func _onCancel() {
        dismiss(animated: true)
    }
}

final class ExchangeAlertView: CWBaseAlertView {
    let bottomView: UIView
    let cancelButton: UIButton
    let doneButton: UIButton
    let innerView: ExchangeContentAlertView
    
    required init() {
        bottomView = UIView()
        cancelButton = SecondaryButton(title: NSLocalizedString("cancel", comment: ""))
        doneButton = PrimaryButton(title: NSLocalizedString("i_saved_sec_key", comment: ""), fontSize: 14)
        innerView = ExchangeContentAlertView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        isOpaque = false
    }
    
    override func configureConstraints() {
        contentView.flex.backgroundColor(.white).alignItems(.center).define { flex in
            flex.addItem(statusImageView).width(100).height(100).alignSelf(.center).position(.absolute).top(-30)
            flex.addItem(titleLabel).margin(UIEdgeInsets(top: 80, left: 30, bottom: 20, right: 30))
            flex.addItem(innerView)
        }
        
        bottomView.flex.position(.absolute).bottom(10).width(width).height(122).justifyContent(.spaceBetween).define { flex in
            flex.addItem(cancelButton).height(56)
            flex.addItem(doneButton).height(56)
        }
        
        super.configureConstraints()
        rootFlexContainer.flex.addItem(bottomView)
    }
}

class CWBaseAlertView: BaseFlexView {
    private static let approximatedDefaultWidth = 325 as CGFloat
    let statusImageView: UIImageView
    let contentView: UIView
    let titleLabel: UILabel
    var width: CGFloat {
        return UIScreen.main.bounds.width > CWBaseAlertView.approximatedDefaultWidth
            ? CWBaseAlertView.approximatedDefaultWidth
            : UIScreen.main.bounds.width - 50 // 50 = 2x25 offset
    }
    
    required init() {
        titleLabel = UILabel(fontSize: 19)
        statusImageView = UIImageView(image: nil)
        contentView = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        isOpaque = true
        rootFlexContainer.backgroundColor = UIColor.whiteSmoke.withAlphaComponent(0.4)
        contentView.layer.masksToBounds = false
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        contentView.layer.shadowRadius = 20
        contentView.layer.shadowOffset = CGSize(width: 2, height: 1)
        contentView.layer.shadowOpacity = 0.3
        contentView.layer.shadowColor = UIColor.lightGray.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.frame.size.height * 0.1
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(contentView).width(width).minHeight(50)
        }
    }
}

