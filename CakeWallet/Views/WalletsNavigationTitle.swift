import UIKit

final class WalletsNavigationTitle: BaseView {
    private static let height: CGFloat = 32
    private static let arrowSize = CGSize(width: 10, height: 6)
    let presentWalletsButton: UIButton
    let titleLabel: UILabel
    let arrowImageView: UIImageView
    var title: String? {
        get { return titleLabel.text }
        set {
            titleLabel.text = newValue
            layoutSubviews()
        }
    }
    var switchHandler: (() -> Void)?
    
    required init() {
        presentWalletsButton = UIButton(type: .custom)
        arrowImageView = UIImageView.init(image: UIImage(named: "arrow_down"))
        titleLabel = UILabel()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        addSubview(titleLabel)
        addSubview(arrowImageView)
        arrowImageView.backgroundColor = .clear
        let onTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(onHandler))
        addGestureRecognizer(onTapGesture)
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.sizeToFit()
        arrowImageView.sizeToFit()
        let margin: CGFloat = 5
        
        let width = titleLabel.frame.size.width + margin + arrowImageView.frame.width
        frame = CGRect(x: 0, y: 0, width: width, height: WalletsNavigationTitle.height)
        titleLabel.frame = CGRect(
            origin: titleLabel.frame.origin,
            size: CGSize(width: titleLabel.frame.size.width, height: WalletsNavigationTitle.height))
        arrowImageView.frame = CGRect(
            origin: CGPoint(x: width - arrowImageView.frame.width, y: (titleLabel.frame.size.height  / 2) - (WalletsNavigationTitle.arrowSize.height / 2)),
            size: WalletsNavigationTitle.arrowSize)
    }
    
    func rotate() {
        arrowImageView.transform = arrowImageView.transform.rotated(by: .pi / 1)
    }
    
    @objc
    private func onHandler() {
        switchHandler?()
    }
}
