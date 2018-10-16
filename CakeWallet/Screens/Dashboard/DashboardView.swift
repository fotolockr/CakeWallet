import UIKit
import PinLayout
import FlexLayout

final class ShortStatusBarView: BaseView {
    let cryptoAmountLabel: UILabel
    let fiatAmountLabel: UILabel
    let receiveButton: UIButton
    let sendButton: UIButton
    let amountContainer: UIView
    
    required init() {
        cryptoAmountLabel = UILabel(fontSize: 18)
        fiatAmountLabel = UILabel(fontSize: 12)
        receiveButton = PrimaryButton(title: NSLocalizedString("receive", comment: ""))
        sendButton = PrimaryButton(title: NSLocalizedString("send", comment: ""))
        amountContainer = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        receiveButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        receiveButton.titleLabel?.numberOfLines = 1
        sendButton.titleLabel?.numberOfLines = 1
        fiatAmountLabel.textColor = .gray
        layer.applySketchShadow(color: UIColor.gray, alpha: 0.34, x: 0, y: 10, blur: 20, spread: -10)
        layer.masksToBounds = false
        layer.cornerRadius = 15
    }
    
    override func configureConstraints() {
        amountContainer.flex.define { flex in
            flex.addItem(cryptoAmountLabel).grow(1).width(100%)
            flex.addItem(fiatAmountLabel).grow(1).width(100%)
        }
        
        flex.direction(.row).padding(10, 15, 10, 15).define { flex in
            flex.addItem(amountContainer).grow(1).marginRight(10)
            flex.addItem(sendButton).height(40).marginRight(10) //.width(65)
            flex.addItem(receiveButton).height(40) //.width(90)
        }
    }
}

final class DashboardView: BaseFlexView {
    let cardView: CardView
    let cryptoIconView: UIImageView
    let progressBar: ProgressBar
    let statusView: UIView
    let statusLabel: UILabel
    let syncingImageView: UIImageView
    let cryptoAmountLabel: UILabel
    let fiatAmountLabel: UILabel
    let cryptoTitleLabel: UILabel
    let receiveButton: UIButton
    let sendButton: UIButton
    let buttonsRow: UIView
    let transactionTitleLabel: UILabel
    let transactionsTableView: UITableView
    let transactionsCardView: CardView
    let tableHeaderView: BaseFlexView
    let shortStatusBarView: ShortStatusBarView
    private var isShowSyncingIconHidden: Bool
    
    required init() {
        cardView = CardView()
        progressBar = ProgressBar()
        statusLabel = UILabel.withLightText(fontSize: 10)
        cryptoAmountLabel = UILabel(fontSize: 33)
        fiatAmountLabel = UILabel.withLightText(fontSize: 16)
        cryptoTitleLabel = UILabel(fontSize: 16)
        cryptoIconView = UIImageView()
        receiveButton = PrimaryButton(title: NSLocalizedString("receive", comment: ""))
        sendButton = PrimaryButton(title: NSLocalizedString("send", comment: ""))
        buttonsRow = UIView()
        transactionTitleLabel = UILabel.withLightText(fontSize: 16)
        transactionsTableView = UITableView()
        transactionsCardView = CardView()
        syncingImageView = UIImageView(image: UIImage(named: "sync_icon"))
        statusView = UIView()
        tableHeaderView = BaseFlexView()
        isShowSyncingIconHidden = false
        shortStatusBarView = ShortStatusBarView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        statusLabel.textAlignment = .center
        cryptoAmountLabel.textAlignment = .center
        fiatAmountLabel.textAlignment = .center
        cryptoTitleLabel.textColor = UIColor.vividBlue
        cryptoTitleLabel.textAlignment = .center
        transactionsTableView.separatorStyle = .none
        tableHeaderView.frame = CGRect(origin: .zero, size: CGSize(width: 0, height: 365))
        transactionsTableView.tableHeaderView = tableHeaderView
        transactionsTableView.tableFooterView = UIView()
        transactionsTableView.backgroundColor = .clear
        transactionsTableView.layoutMargins = .zero
        transactionsTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -18)
        transactionsTableView.separatorInset = .zero
        transactionTitleLabel.text = NSLocalizedString("transactions", comment: "")
        transactionTitleLabel.textAlignment = .center
        syncingImageView.isHidden = true
        tableHeaderView.backgroundColor = .clear
        tableHeaderView.rootFlexContainer.flex.backgroundColor(.clear)
        transactionsTableView.layer.masksToBounds = false
        rootFlexContainer.layer.masksToBounds = true
    }
    
    override func configureConstraints() {
        statusView.flex.direction(.row).justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(syncingImageView).height(12).width(12)
            flex.addItem(statusLabel).height(100%).width(100%)
        }
        
        cardView.flex.alignItems(.center).padding(20, 20, 30, 20).justifyContent(.spaceBetween).alignItems(.center).define { flex in
            flex.addItem(cryptoIconView).minHeight(21).minWidth(21).marginBottom(17)
            flex.addItem(cryptoTitleLabel).width(100%).marginBottom(10)
            flex.addItem(cryptoAmountLabel).width(100%).marginLeft(30).marginRight(30)
            flex.addItem(fiatAmountLabel).width(100%).marginTop(5).marginLeft(30).marginRight(30)
            flex.addItem(statusView).width(100%).marginTop(30).height(30)
            flex.addItem(progressBar).width(100%).height(4)
        }
        
        buttonsRow.flex.direction(.row).justifyContent(.spaceBetween).marginTop(15).define { flex in
            flex.addItem(sendButton).height(56).width(45%)
            flex.addItem(receiveButton).height(56).width(45%)
        }
        
        transactionsCardView.flex.padding(20, 0, 20, 0).define { flex in
            flex.addItem(transactionsTableView).marginLeft(10).grow(1).minHeight(40)
        }
        
        rootFlexContainer.flex.define { flex in
            flex.addItem(transactionsTableView).margin(UIEdgeInsets(top: 20, left: 15, bottom: 20, right: 20))
            flex.addItem(shortStatusBarView).position(.absolute).width(100%) //.top(35)
        }
        
        tableHeaderView.rootFlexContainer.flex.padding(20).margin(-20).define { flex in
            flex.addItem(cardView)
            flex.addItem(buttonsRow).marginTop(15)
            flex.addItem(transactionTitleLabel).marginTop(15)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableHeaderView.layoutSubviews()
    }
    
    func showSyncingIcon() {
        guard !isShowSyncingIconHidden else { return }
        isShowSyncingIconHidden = true
        syncingImageView.isHidden = false
        syncingImageView.flex.size(CGSize(width: 12, height: 12))
        syncingImageView.flex.markDirty()
    }
    
    func hideSyncingIcon() {
        guard isShowSyncingIconHidden else { return }
        isShowSyncingIconHidden = false
        syncingImageView.isHidden = true
        syncingImageView.flex.size(CGSize(width: 1, height: 1))
        syncingImageView.flex.markDirty()
    }
    
    func updateStatus(text: String) {
        statusLabel.text = text
//        statusLabel.flex.layout()
//        statusLabel.flex.markDirty()
//        statusView.flex.layout()
//        statusView.flex.markDirty()
    }
}
