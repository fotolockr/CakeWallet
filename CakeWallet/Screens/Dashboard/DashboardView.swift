import UIKit
import PinLayout
import FlexLayout

enum DashboardActionType {
    case send, receive
    
    var title: String {
        switch self {
        case .send:
            return "Send"
        case .receive:
            return "Receive"
        }
    }
    
    var image: UIImage {
        switch self {
        case .send:
            return UIImage(named: "send_button_icon")!
        case .receive:
            return UIImage(named: "receive_button_icon")!
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .send:
            return UIColor(red: 209, green: 189, blue: 245)
        case .receive:
            return UIColor(red: 152, green: 228, blue: 227)
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .send:
            return UIColor(red: 244, green: 239, blue: 253)
        case .receive:
            return UIColor(red: 235, green: 248, blue: 250)
        }
    }
}

final class DashboardActionButton: BaseFlexView {
    let type: DashboardActionType
    let wrapper: UIView
    let label: UILabel
    let buttonImageView: UIImageView
    
    required init(type: DashboardActionType) {
        self.type = type
        wrapper = UIView()
        label = UILabel(text: type.title)
        buttonImageView = UIImageView()
        
        super.init()
    }
    
    required init() {
        self.type = .send
        wrapper = UIView()
        label = UILabel()
        buttonImageView = UIImageView()
        
        super.init()
    }
    
    override func configureView() {
        label.font = applyFont(ofSize: 17, weight: .semibold)
        
        wrapper.layer.cornerRadius = 12
        wrapper.layer.borderWidth = 1
        wrapper.layer.borderColor = type.borderColor.cgColor
        wrapper.applyCardSketchShadow()
        
        buttonImageView.image = type.image
        
        super.configureView()
    }
    
    override func configureConstraints() {
        wrapper.flex
            .justifyContent(.center)
            .alignItems(.center)
            .backgroundColor(type.backgroundColor)
            .define{ flex in
                flex.addItem(buttonImageView).position(.absolute).top(17).left(15)
                flex.addItem(label).marginLeft(12)
        }
        
        rootFlexContainer.flex
            .height(60)
            .backgroundColor(.white)
            .define { flex in
                flex.addItem(wrapper).width(100%).height(100%)
        }
    }
}

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
    
    override func configureConstraints() {
        amountContainer.flex.define { flex in
            flex.addItem(cryptoAmountLabel).grow(1).width(100%)
            flex.addItem(fiatAmountLabel).grow(1).width(100%)
        }
        
        flex.direction(.row).padding(10, 15, 10, 15).define { flex in
            flex.addItem(amountContainer).grow(1).marginRight(10)
            flex.addItem(sendButton).height(40).marginRight(10)
            flex.addItem(receiveButton).height(40)
        }
    }
}

final class DashboardView: BaseFlexView {
    let transactionsCardView: CardView
    let cardView: UIView
    let fiatAmountLabel, cryptoAmountLabel, statusLabel, cryptoTitleLabel, transactionTitleLabel: UILabel
    let progressBar: ProgressBar
    let statusView, buttonsRow: UIView
    let syncingImageView: UIImageView
    let receiveButton, sendButton: DashboardActionButton
    let transactionsTableView: UITableView
    let tableHeaderView: BaseFlexView
    let shortStatusBarView: ShortStatusBarView
    private var isShowSyncingIconHidden: Bool
    
    required init() {
        cardView = UIView()
        progressBar = ProgressBar()
        statusLabel = UILabel.withLightText(fontSize: 10)
        cryptoAmountLabel = UILabel()
        fiatAmountLabel = UILabel.withLightText(fontSize: 17)
        cryptoTitleLabel = UILabel(fontSize: 16)
        receiveButton = DashboardActionButton(type: .receive)
        sendButton = DashboardActionButton(type: .send)
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
        cryptoAmountLabel.font = applyFont(ofSize: 40)
        cryptoAmountLabel.textAlignment = .center
        fiatAmountLabel.textAlignment = .center
        fiatAmountLabel.font = applyFont(ofSize: 17)
        
        cryptoTitleLabel.font = applyFont(ofSize: 16, weight: .semibold)
        cryptoTitleLabel.textColor = UIColor.purpley
        cryptoTitleLabel.textAlignment = .center
        
        transactionsTableView.separatorStyle = .none
        tableHeaderView.frame = CGRect(origin: .zero, size: CGSize(width: 0, height: 310))
        transactionsTableView.tableHeaderView = tableHeaderView
        transactionsTableView.tableFooterView = UIView()
        transactionsTableView.layoutMargins = .zero
        transactionsTableView.separatorInset = .zero
        transactionTitleLabel.text = NSLocalizedString("transactions", comment: "")
        transactionTitleLabel.textAlignment = .center
        syncingImageView.isHidden = true
        tableHeaderView.backgroundColor = .clear
        tableHeaderView.rootFlexContainer.flex.backgroundColor(.clear)
        transactionsTableView.layer.masksToBounds = false
        rootFlexContainer.layer.masksToBounds = true
        backgroundColor = UIColor.white
    }
    
    override func configureConstraints() {
        let cardViewCoreDataWrapper = UIView()
        let cardViewStatusBarUIWrapper = UIView()
        let buttonsRowPadding = adaptiveLayout.getSize(forLarge: 50, forBig: 45, defaultSize: 45)
        
        statusView.flex
            .direction(.row)
            .justifyContent(.center)
            .alignItems(.center)
            .define { flex in
                flex.addItem(syncingImageView).height(12).width(12)
                flex.addItem(statusLabel).height(100%).width(100%).marginRight(syncingImageView.isHidden ? 12 : 0)
        }
    
        cardViewCoreDataWrapper.flex
            .alignItems(.center)
            .paddingTop(20)
            .width(100%)
            .define{ flex in
                flex.addItem(cryptoTitleLabel).marginBottom(8).width(100%)
                flex.addItem(cryptoAmountLabel).marginBottom(10).width(100%)
                flex.addItem(fiatAmountLabel).width(100%)
        }
        
        cardViewStatusBarUIWrapper.flex
            .alignItems(.center)
            .define{ flex in
                flex.addItem(statusView).width(100%).marginBottom(8)
                flex.addItem(progressBar).width(85%).height(4)
        }
        
        cardView.flex
            .alignItems(.center).justifyContent(.spaceBetween).alignItems(.center)
            .width(100%).padding(20).marginTop(15)
            .backgroundColor(.white)
            .define { flex in
                flex.addItem(cardViewCoreDataWrapper).marginBottom(29)
                flex.addItem(cardViewStatusBarUIWrapper).width(100%)
        }
        
        buttonsRow.flex
            .direction(.row)
            .justifyContent(.spaceBetween)
            .marginTop(15).paddingHorizontal(buttonsRowPadding)
            .backgroundColor(.clear)
            .define { flex in
                flex.addItem(sendButton).width(48%)
                flex.addItem(receiveButton).width(48%)
        }
        
        transactionsCardView.flex
            .padding(30, 0, 20, 0)
            .define { flex in
                flex.addItem(transactionsTableView).marginLeft(10).grow(1).minHeight(40)
        }
        
        rootFlexContainer.flex
            .backgroundColor(.white)
            .define { flex in
                flex.addItem(transactionsTableView).margin(UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
//                flex.addItem(shortStatusBarView).position(.absolute).width(100%)
        }
        
//        tableHeaderView.layer.borderWidth = 1
        
        tableHeaderView.rootFlexContainer.flex
            .alignItems(.center)
//            .padding(20)
//            .backgroundColor(.white)
            .margin(-35)
            .define { flex in
                flex.addItem(cardView).width(92%)
                 flex.addItem(buttonsRow).marginTop(15).width(92%)
                // flex.addItem(transactionTitleLabel).marginTop(30)
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
    }
}
