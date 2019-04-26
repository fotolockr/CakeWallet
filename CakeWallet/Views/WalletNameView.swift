import UIKit

final class WalletNameView: BaseView {
    private static let titleHeight = 20 as CGFloat
    private static let offsetTop = 12 as CGFloat
    private static let subtitleHeight = 16 as CGFloat
    private static let maxWidth = 132 as CGFloat
    let titleLabel: UILabel
    let subtitleLabel: UILabel
    var title: String? {
        get { return titleLabel.text }
        set { titleLabel.text = newValue }
    }
    var subtitle: String? {
        get { return subtitleLabel.text }
        set { subtitleLabel.text = newValue }
    }
    var onTap: (() -> Void)?
    
    required init() {
        titleLabel = UILabel(frame: CGRect(
            origin: CGPoint(x: 0, y: WalletNameView.offsetTop),
            size: CGSize(width: WalletNameView.maxWidth, height: WalletNameView.titleHeight)))
        subtitleLabel = UILabel(frame: CGRect(
            origin: CGPoint(x: 0, y: (titleLabel.frame.origin.y - 4) + titleLabel.frame.size.height),
            size: CGSize(width: WalletNameView.maxWidth, height: WalletNameView.subtitleHeight)))
        super.init()
        let height = WalletNameView.titleHeight + WalletNameView.offsetTop + WalletNameView.subtitleHeight
        frame = CGRect(origin: frame.origin, size: CGSize(width: WalletNameView.maxWidth, height: height))
    }
    
    override func configureView() {
        super.configureView()
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        let onTapGesture = UITapGestureRecognizer(target: self, action: #selector(onHandler))
        addGestureRecognizer(onTapGesture)
        backgroundColor = .clear
        titleLabel.font = UIFont(name: "Lato-Regular", size: 20.0)
        subtitleLabel.font = UIFont(name: "Lato-Regular", size: 10.0)
        titleLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center
    }
    
    @objc
    private func onHandler() {
        onTap?()
    }
}
