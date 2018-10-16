import UIKit

final class CWAlertAction: BaseView {
    enum Style {
        case `default`, cancel
    }
    
    static let defaultHeight = 50 as CGFloat
    
    static var okAction: CWAlertAction {
        return CWAlertAction(
            title: NSLocalizedString("ok", comment: ""),
            handler: { $0.alertView?.dismiss(animated: true) }
        )
    }
    
    static var cancelAction: CWAlertAction {
        return CWAlertAction(
            title: NSLocalizedString("cancel", comment: ""),
            style: .cancel,
            handler: { $0.alertView?.dismiss(animated: true) }
        )
    }
    
    let titleLabel: UILabel
    let title: String
    let handler: (CWAlertAction) -> Void
    let style: Style
    weak var alertView: CWAlertViewController?
    
    init(title: String, style: Style = .default, handler: @escaping (CWAlertAction) -> Void) {
        self.style = style
        titleLabel = UILabel(font: style == .default ? UIFont.systemFont(ofSize: 19) : UIFont.boldSystemFont(ofSize: 19))
        self.title = title
        self.handler = handler
        super.init()
    }
    
    required init() {
        self.style = .default
        titleLabel = UILabel(font: style == .default ? UIFont.systemFont(ofSize: 19) : UIFont.boldSystemFont(ofSize: 19))
        self.title = NSLocalizedString("ok", comment: "")
        self.handler = { $0.alertView?.dismiss(animated: true) }
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        backgroundColor = .clear
        let onTapGesture = UITapGestureRecognizer(target: self, action: #selector(_handler))
        addGestureRecognizer(onTapGesture)
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .blueBolt
        addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(origin: .zero, size: frame.size)
    }
    
    @objc
    private func _handler() {
        handler(self)
    }
}
