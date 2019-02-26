import UIKit
import FlexLayout

final class RestoreRootView: BaseScrollFlexView {
    let restoreWalletCard: UIView
    let restoreWalletImage: UIImageView
    let restoreWalletTitle: UILabel
    let restoreWalletDescription: UILabel
    let restoreWalletButtonSeparatorView: UIView
    let restoreWalletButton: UIButton
    let restoreWalletButtonText: UILabel
    
    let restoreAppCard: UIView
    let restoreAppImage: UIImageView
    let restoreAppTitle: UILabel
    let restoreAppDescription: UILabel
    let restoreAppButtonSeparatorView: UIView
    let restoreAppButton: UIButton
    let restoreAppButtonText: UILabel
    
    required init() {
        restoreWalletCard = UIView()
        restoreWalletImage = UIImageView(image: UIImage(named: "restore_wallet_image"))
        restoreWalletTitle = UILabel()
        restoreWalletDescription = UILabel()
        restoreWalletButtonSeparatorView = UIView()
        restoreWalletButton = UIButton()
        restoreWalletButtonText = UILabel()
        
        restoreAppCard = UIView()
        restoreAppImage = UIImageView(image: UIImage(named: "restore_app_image"))
        restoreAppTitle = UILabel()
        restoreAppDescription = UILabel()
        restoreAppButtonSeparatorView = UIView()
        restoreAppButton = UIButton()
        restoreAppButtonText = UILabel()
        
        super.init()
    }
    
    override func configureView() {
        super.configureView()
  
        restoreWalletCard.layer.cornerRadius = 12
        restoreWalletCard.layer.applySketchShadow(color: UIColor(hex: 0x29174d), alpha: 0.1, x: 0, y: 10, blur: 10, spread: -3)
        restoreWalletCard.backgroundColor = Theme.current.card.background
        restoreWalletTitle.font = applyFont(ofSize: 20, weight: .semibold)
        restoreWalletTitle.textColor = .purpley
        restoreWalletDescription.font = applyFont(ofSize: 16)
        restoreWalletDescription.textColor = .greyBlue
        restoreWalletDescription.numberOfLines = 2
        restoreWalletDescription.textAlignment = .center
        restoreWalletButtonText.font = applyFont(ofSize: 18, weight: .semibold)
        restoreWalletButtonText.textColor = .purpley
        
        restoreAppCard.layer.cornerRadius = 12
        restoreAppCard.layer.applySketchShadow(color: UIColor(hex: 0x29174d), alpha: 0.1, x: 0, y: 10, blur: 10, spread: -3)
        restoreAppCard.backgroundColor = Theme.current.card.background
        restoreAppTitle.font = applyFont(ofSize: 20, weight: .semibold)
        restoreAppTitle.textColor = .turquoiseBlue
        restoreAppDescription.font = applyFont(ofSize: 16)
        restoreAppDescription.textColor = .greyBlue
        restoreAppDescription.numberOfLines = 2
        restoreAppDescription.textAlignment = .center
        restoreAppButtonText.font = applyFont(ofSize: 18, weight: .semibold)
        restoreAppButtonText.textColor = .turquoiseBlue
    }
    
    override func configureConstraints() {
        restoreWalletCard.flex.alignItems(.center)
            .width(100%)
            .padding(0, 0, 50, 0)
            .marginBottom(25).define{ flex in
                flex.addItem(restoreWalletImage)
                flex.addItem(restoreWalletTitle)
                flex.addItem(restoreWalletDescription).padding(0, 15, 35, 15)
                flex.addItem(restoreWalletButtonSeparatorView).width(100%).height(1).backgroundColor(.veryLightBlue)
                flex.addItem(restoreWalletButton)
                    .position(.absolute)
                    .bottom(0)
                    .alignItems(.center)
                    .justifyContent(.center)
                    .width(100%)
                    .height(50).define({ wrapperFlex in wrapperFlex.addItem(restoreWalletButtonText)})
        }
        
        restoreAppCard.flex.alignItems(.center)
            .width(100%)
            .padding(0, 0, 50, 0).define{ flex in
                flex.addItem(restoreAppImage)
                flex.addItem(restoreAppTitle)
                flex.addItem(restoreAppDescription).padding(0, 15, 35, 15)
                flex.addItem(restoreAppButtonSeparatorView).width(100%).height(1).backgroundColor(.veryLightBlue)
                flex.addItem(restoreAppButton)
                    .position(.absolute)
                    .bottom(0)
                    .alignItems(.center)
                    .justifyContent(.center)
                    .width(100%)
                    .height(50).define({ wrapperFlex in
                        wrapperFlex.addItem(restoreAppButtonText)
                    })
        }
        
        rootFlexContainer.flex.alignItems(.center).padding(15).define { flex in
            flex.addItem(restoreWalletCard)
            flex.addItem(restoreAppCard)
        }
    }
}

