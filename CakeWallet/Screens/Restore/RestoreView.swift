import UIKit
import FlexLayout

final class RestoreView: BaseScrollFlexView {
    let restoreFromSeedCard: WelcomeFlowCardView
    let restoreFromKeysCard: WelcomeFlowCardView
    
    required init() {
        restoreFromSeedCard = WelcomeFlowCardView(
            withImage: "restore_seed_image",
            withTitle: "Restore from seed",
            withDescription: "Restore your wallet from 12 word combination code.",
            withColor: .purpley
        )
        
        restoreFromKeysCard = WelcomeFlowCardView(
            withImage: "restore_keys_image",
            withTitle: "Restore from keys",
            withDescription: "Restore your wallet from generated keystrokes saved from previous wallet",
            withColor: .turquoiseBlue
        )

        super.init()
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.alignItems(.center).padding(5).define { flex in
            flex.addItem(restoreFromSeedCard)
            flex.addItem(restoreFromKeysCard)
        }
    }
}
