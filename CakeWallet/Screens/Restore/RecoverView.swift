import UIKit
import FlexLayout

final class RecoverView: BaseScrollFlexView {
    let imageView: UIImageView
    let titleLabel: UILabel
    let fromSeedButton: UIButton
    let fromKeysButton: UIButton
    let orLabel: UILabel
    let buttonsContainer: UIView
    let cryptoIconImageView: UIImageView
    let imageContainer: UIView
    let descriptionLabel: UILabel
    
    required init() {
        imageView = UIImageView(image: UIImage(named: "new_wallet_logo"))
        titleLabel = UILabel(fontSize: 24)
        fromSeedButton = PrimaryButton(title: NSLocalizedString("from_seed", comment: ""))
        fromKeysButton = SecondaryButton(title: NSLocalizedString("from_keys", comment: ""))
        buttonsContainer = UIView()
        orLabel = UILabel.withLightText(fontSize: 14)
        cryptoIconImageView = UIImageView(image: nil)
        imageContainer = UIView()
        descriptionLabel = UILabel.withLightText(fontSize: 16)
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        orLabel.text = NSLocalizedString("or", comment: "")
        orLabel.textAlignment = .center
        titleLabel.textAlignment = .center
        descriptionLabel.textAlignment = .center
        
        buttonsContainer.flex.define { flex in
            flex.addItem(fromSeedButton).height(56)
            flex.addItem(orLabel).margin(UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
            flex.addItem(fromKeysButton).height(56)
        }
    }
    
    override func configureConstraints() {
        imageContainer.flex.width(256).height(223).define { flex in
            flex.addItem(imageView)
            flex.addItem(cryptoIconImageView).position(.absolute).top(75).right(90).width(32).height(32)
        }
        
        rootFlexContainer.flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(imageContainer)
            flex.addItem(titleLabel).width(80%)
            flex.addItem(descriptionLabel).width(80%).marginTop(20)
            flex.addItem(buttonsContainer).width(80%).marginTop(80).marginBottom(20)
        }
    }
}
