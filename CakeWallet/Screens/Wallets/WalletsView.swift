import UIKit
import FlexLayout

final class WalletsView: BaseScrollFlexViewWithBottomSection {
    let walletsTableView: UITableView
    let walletsCardView: CardView
    let createWalletButton: UIButton
    let restoreWalletButton: UIButton

    required init() {
        walletsTableView = UITableView()
        walletsCardView = CardView()
        createWalletButton = StandartButton(title: NSLocalizedString("create_new_wallet", comment: ""))
        restoreWalletButton = StandartButton(title: NSLocalizedString("restore_wallet", comment: ""))
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        walletsTableView.rowHeight = 50
        walletsTableView.isScrollEnabled = false
        walletsTableView.backgroundColor = .clear
        createWalletButton.setImage(UIImage(named: "add_icon_purple")?.resized(to: CGSize(width: 30, height: 30)), for: .normal)
        createWalletButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        createWalletButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        createWalletButton.contentHorizontalAlignment = .left
        restoreWalletButton.setImage(UIImage(named: "recover_icon"), for: .normal)
        restoreWalletButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        restoreWalletButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        restoreWalletButton.contentHorizontalAlignment = .left
        backgroundColor = .white
    }
    
    override func configureConstraints() {
        let adaptivePadding = adaptiveLayout.getSize(forLarge: 40, forBig: 35, defaultSize: 30)
        
        rootFlexContainer.flex.backgroundColor(.clear).padding(0, 20, 20, adaptivePadding).define { flex in
            flex.addItem(walletsTableView).marginTop(20)
        }
        
        bottomSectionView.flex.padding(0, 15, 0, 15).define { flex in
            flex.addItem(createWalletButton).height(72).backgroundColor(.purpleyLight)
            flex.addItem(restoreWalletButton).height(72).marginTop(10).backgroundColor(UIColor(hex: 0xD8DFF7))
        }
    }
}
