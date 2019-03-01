import UIKit
import FlexLayout

final class RestoreView: BaseScrollFlexView {
    let restoreFromSeedImageView: FlexView
    let restoreFromSeedImage: UIImageView
    let restoreFromSeedCard: WelcomeFlowCardView
    
    let restoreFromKeysImageView: FlexView
    let restoreFromKeysImage: UIImageView
    let restoreFromKeysCard: WelcomeFlowCardView
    
    required init() {
        restoreFromSeedImageView = FlexView()
        restoreFromSeedImage = UIImageView(image: UIImage(named: "restore_seed_image"))
        restoreFromSeedCard = WelcomeFlowCardView(
            imageView: restoreFromSeedImageView,
            titleText: "Restore from seed",
            descriptionText: "Restore your wallet from either the 25 word or 12 word seed",
            textColor: .purpley
        )
        
        restoreFromKeysImageView = FlexView()
        restoreFromKeysImage = UIImageView(image: UIImage(named: "restore_keys_image"))
        restoreFromKeysCard = WelcomeFlowCardView(
            imageView: restoreFromKeysImageView,
            titleText: "Restore from keys",
            descriptionText: "Restore your wallet from your private keys",
            textColor: .turquoiseBlue
        )
        
        super.init()
    }
    
    override func configureConstraints() {
        restoreFromSeedImageView.constraintsSetup = { [weak self] root in
            root.flex.padding(45, 0, 15, 0).backgroundColor(Theme.current.card.background).define { flex in
                if let restoreFromSeedImage = self?.restoreFromSeedImage {
                    flex.addItem(restoreFromSeedImage).height(100).width(240)
                }
            }
        }
        
        restoreFromKeysImageView.constraintsSetup = { [weak self] root in
            root.flex.padding(45, 0, 15, 0).backgroundColor(Theme.current.card.background).define { flex in
                if let restoreFromKeysImage = self?.restoreFromKeysImage {
                    flex.addItem(restoreFromKeysImage).height(100).width(240)
                }
            }
        }
        
        rootFlexContainer.flex.alignItems(.center).padding(20).define { flex in
             flex.addItem(restoreFromSeedCard).width(100%)
            flex.addItem(restoreFromKeysCard).width(100%)
        }
    }
}
