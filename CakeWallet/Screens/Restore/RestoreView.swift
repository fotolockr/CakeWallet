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
            titleText: NSLocalizedString("restore_seed_card_title", comment: ""),
            descriptionText: NSLocalizedString("restore_seed_card_description", comment: ""),
            textColor: .purpley
        )
        
        restoreFromKeysImageView = FlexView()
        restoreFromKeysImage = UIImageView(image: UIImage(named: "restore_keys_image"))
        restoreFromKeysCard = WelcomeFlowCardView(
            imageView: restoreFromKeysImageView,
            titleText: NSLocalizedString("restore_keys_card_title", comment: ""),
            descriptionText: NSLocalizedString("restore_keys_card_description", comment: ""),
            textColor: .turquoiseBlue
        )
        
        super.init()
    }
    
    override func configureConstraints() {
        let imageViewBackgroundColor = Theme.current.card.background
        let imageHeight = adaptiveLayout.getSize(forLarge: 135, forBig: 100, defaultSize: 85)
        let imageWidth = adaptiveLayout.getSize(forLarge: 290, forBig: 240, defaultSize: 200)
        let imagePaddingTop = adaptiveLayout.getSize(forLarge: 50, forBig: 50, defaultSize: 30)
        
        restoreFromSeedImageView.constraintsSetup = { [weak self] root in
            root.flex.padding(imagePaddingTop, 0, 10, 0).backgroundColor(imageViewBackgroundColor).define { flex in
                if let restoreFromSeedImage = self?.restoreFromSeedImage {
                    flex.addItem(restoreFromSeedImage)
                        .height(imageHeight)
                        .width(imageWidth)
                }
            }
        }
        
        restoreFromKeysImageView.constraintsSetup = { [weak self] root in
            root.flex.padding(imagePaddingTop, 0, 10, 0).backgroundColor(imageViewBackgroundColor).define { flex in
                if let restoreFromKeysImage = self?.restoreFromKeysImage {
                    flex.addItem(restoreFromKeysImage)
                        .height(imageHeight)
                        .width(imageWidth)
                }
            }
        }
        
        rootFlexContainer.flex.alignItems(.center).padding(15, 20, 15, 20).define { flex in
             flex.addItem(restoreFromSeedCard).width(100%)
            flex.addItem(restoreFromKeysCard).width(100%)
        }
    }
}
