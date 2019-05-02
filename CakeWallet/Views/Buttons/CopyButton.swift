import UIKit


final class CopyButton: SecondaryButton {
    var textHandler: (() -> String)?
    weak var alertPresenter: UIViewController?
    
    override func configureView() {
        super.configureView()
        addTarget(self, action: #selector(onTouchAction), for: .touchUpInside)
    }
    
    @objc
    private func onTouchAction() {
        guard
            let text = textHandler?(),
            !text.isEmpty else { return }
        UIPasteboard.general.string = text
        alertPresenter?.showDurationInfoAlert(title: NSLocalizedString("copied", comment: ""), message: "", duration: 1)
    }
}


class IconedCopyButton: UIButton {
    init() {
        super.init(frame: .zero)
        setImage(UIImage(named: "copy_icon_dark"), for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 5
        imageEdgeInsets = UIEdgeInsetsMake(9, 9, 9, 9)
        backgroundColor = UIColor.whiteSmoke
    }
}
