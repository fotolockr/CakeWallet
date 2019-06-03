import UIKit
import FlexLayout

final class ExchangeNameView: BaseView {
    private static let titleHeight = 20 as CGFloat
    private static let subtitleHeight = 12 as CGFloat
    private static let maxWidth = 132 as CGFloat
    private static let arrowImageViewLeftOffset = 8 as CGFloat
    let titleLabel: UILabel
    let subtitleLabel: UILabel
    var title: String? {
        get { return titleLabel.text }
        set {
            titleLabel.text = newValue
            layout()
        }
    }
    var subtitle: String? {
        get { return subtitleLabel.text }
        set {
            subtitleLabel.text = newValue
            layout()
        }
    }
    var onTap: (() -> Void)?
    let arrowDownImageView: UIImageView
    
    required init() {
        titleLabel = UILabel(frame: CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: ExchangeNameView.maxWidth, height: ExchangeNameView.titleHeight)))
        subtitleLabel = UILabel(frame: CGRect(
            origin: CGPoint(x: 0, y: (titleLabel.frame.origin.y - 4) + titleLabel.frame.size.height),
            size: CGSize(width: 30, height: ExchangeNameView.subtitleHeight)))
        arrowDownImageView = UIImageView(image: UIImage(named: "arrow_bottom_purple_icon"))
        super.init()
        let height = ExchangeNameView.titleHeight + ExchangeNameView.subtitleHeight
        frame = CGRect(origin: frame.origin, size: CGSize(width: ExchangeNameView.maxWidth + 20, height: height))
    }
    
    override func configureView() {
        super.configureView()
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(arrowDownImageView)
        let onTapGesture = UITapGestureRecognizer(target: self, action: #selector(onHandler))
        addGestureRecognizer(onTapGesture)
        backgroundColor = .clear
        titleLabel.font = applyFont(ofSize: 16)
        subtitleLabel.font = applyFont(ofSize: 10)
        titleLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center
    }
    
    @objc
    private func onHandler() {
        onTap?()
    }
    
    private func layout() {
        layoutTitleLabel()
        layoutSubtitleLabel()
        layoutArrowDownLayout()
    }
    
    private func layoutTitleLabel() {
        let estimatedSize = titleLabel.sizeThatFits(CGSize(width: 0, height: ExchangeNameView.titleHeight))
        let xPosition = frame.size.width / 2 - estimatedSize.width / 2
        titleLabel.frame = CGRect(origin: CGPoint(x: xPosition, y: titleLabel.frame.origin.y), size: CGSize(width: estimatedSize.width, height: ExchangeNameView.titleHeight))
    }
    
    private func layoutSubtitleLabel() {
        let estimatedSize = subtitleLabel.sizeThatFits(CGSize(width: 0, height: ExchangeNameView.subtitleHeight))
        let xPosition = frame.size.width / 2 - estimatedSize.width / 2
        let yPosition = titleLabel.frame.origin.y + titleLabel.frame.size.height
        subtitleLabel.frame = CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: CGSize(width: estimatedSize.width, height: ExchangeNameView.subtitleHeight))
    }
    
    private func layoutArrowDownLayout() {
        let leftFrame = titleLabel.frame.size.width > subtitleLabel.frame.size.width ? titleLabel.frame : subtitleLabel.frame
        let xPosition = leftFrame.origin.x + leftFrame.size.width + ExchangeNameView.arrowImageViewLeftOffset
        let yPosition = frame.size.height / 2 - arrowDownImageView.frame.size.height / 2
        arrowDownImageView.frame = CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: arrowDownImageView.frame.size)
    }
}

