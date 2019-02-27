import UIKit
import FlexLayout

final class RestoreRootView: BaseScrollFlexView {
    let restoreWalletCard: WelcomeFlowCardView
    let restoreAppCard: WelcomeFlowCardView

    required init() {
        restoreWalletCard = WelcomeFlowCardView(
            withImage: "restore_wallet_image",
            withTitle: "Restore from seed/keys",
            withDescription: "Get back your wallet from seed/keys that you’ve saved to secure place.",
            withColor: .purpley
        )
        
        restoreAppCard = WelcomeFlowCardView(
            withImage: "restore_app_image",
            withTitle: "Restore app from backup file",
            withDescription: "You can restore the whole app from a backed-up file.",
            withColor: .turquoiseBlue
        )
        
        super.init()
    }
    
    override func configureConstraints() {
        rootFlexContainer.flex.alignItems(.center).padding(5).define { flex in
            flex.addItem(restoreWalletCard)
            flex.addItem(restoreAppCard)
        }
    }
}

