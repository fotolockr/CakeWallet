import UIKit
import CakeWalletLib
import CakeWalletCore
import FlexLayout

final class DashboardController: BaseViewController<DashboardView>, StoreSubscriber, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    let walletNameView = WalletNameView()
    weak var dashboardFlow: DashboardFlow?
    private var showAbleBalance: Bool
    private(set) var presentWalletsListButtonTitle: UIBarButtonItem?
    private(set) var presentWalletsListButtonImage: UIBarButtonItem?
    private var transactions: [TransactionDescription] = []
    private var sortedTransactions:  [DateComponents : [TransactionDescription]] = [:] {
        didSet {
            transactionsKeys = sort(dateComponents: Array(sortedTransactions.keys))
        }
    }
    private var transactionsKeys: [DateComponents] = []
    private var initialHeight: UInt64
    private var refreshControl: UIRefreshControl
    let store: Store<ApplicationState>
    
    init(store: Store<ApplicationState>, dashboardFlow: DashboardFlow?) {
        self.store = store
        self.dashboardFlow = dashboardFlow
        showAbleBalance = true
        initialHeight = 0
        refreshControl = UIRefreshControl()
        super.init()
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: "wallet_icon")?.resized(to: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "wallet_selected_icon")?.resized(to: CGSize(width: 28, height: 28)).withRenderingMode(.alwaysOriginal)
        )
    }
    
    override func configureBinds() {
        navigationController?.navigationBar.backgroundColor = .clear
        
        contentView.transactionsTableView.register(items: [TransactionDescription.self])
        contentView.transactionsTableView.delegate = self
        contentView.transactionsTableView.dataSource = self
        contentView.transactionsTableView.addSubview(refreshControl)
        contentView.transactionsTableView.bringSubview(toFront: contentView.tableHeaderView)
        
        contentView.shortStatusBarView.receiveButton.addTarget(self, action: #selector(presentReceive), for: .touchUpInside)
        contentView.shortStatusBarView.sendButton.addTarget(self, action: #selector(presentSend), for: .touchUpInside)
        contentView.shortStatusBarView.isHidden = true
        
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        
        let onCryptoAmountTap = UITapGestureRecognizer(target: self, action: #selector(changeShownBalance))
        contentView.cryptoAmountLabel.isUserInteractionEnabled = true
        contentView.cryptoAmountLabel.addGestureRecognizer(onCryptoAmountTap)
        
        let sendButtonTap = UITapGestureRecognizer(target: self, action: #selector(presentSend))
        contentView.sendButton.isUserInteractionEnabled = true
        contentView.sendButton.addGestureRecognizer(sendButtonTap)
        
        let receiveButtonTap = UITapGestureRecognizer(target: self, action: #selector(presentReceive))
        contentView.receiveButton.isUserInteractionEnabled = true
        contentView.receiveButton.addGestureRecognizer(receiveButtonTap)
        
        walletNameView.onTap = { [weak self] in
            self?.presentWalletActions()
        }

        insertNavigationItems()
    }
    
    private func insertNavigationItems() {
        presentWalletsListButtonTitle = UIBarButtonItem(
            title: "Change",
            style: .plain,
            target: self,
            action: #selector(presentWalletsList)
        )
        
        presentWalletsListButtonImage = UIBarButtonItem(
            image: UIImage(named: "arrow_bottom_purple_icon")?
                .resized(to: CGSize(width: 11, height: 9)).withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(presentWalletsList)
        )
        
        presentWalletsListButtonTitle?.tintColor = .vividBlue
        presentWalletsListButtonImage?.tintColor = .vividBlue

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "more")?.resized(to: CGSize(width: 28, height: 28)), style: .plain, target: self, action: #selector(presentWalletActions))
        navigationItem.titleView = walletNameView
        
        if let presentWalletsListButtonTitle = presentWalletsListButtonTitle,
           let presentWalletsListButtonImage = presentWalletsListButtonImage {
            
            presentWalletsListButtonTitle.setTitleTextAttributes([
                NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: 13.0)!,
                NSAttributedStringKey.foregroundColor: UIColor.wildDarkBlue
            ], for: .normal)
            
            presentWalletsListButtonTitle.setTitleTextAttributes([
                NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: 13.0)!,
                NSAttributedStringKey.foregroundColor: UIColor.wildDarkBlue
            ], for: .highlighted)
            
            navigationItem.rightBarButtonItems = [presentWalletsListButtonImage, presentWalletsListButtonTitle]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.dispatch(TransactionsActions.forceUpdateTransactions)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    override func setTitle() {
        title = NSLocalizedString("wallet", comment: "")
    }
    
    func onStateChange(_ state: ApplicationState) {
        updateStatus(state.blockchainState.connectionStatus)
        updateCryptoBalance(showAbleBalance ? state.balanceState.unlockedBalance : state.balanceState.balance)
        updateFiatBalance(showAbleBalance ? state.balanceState.unlockedFiatBalance : state.balanceState.fullFiatBalance)
        onWalletChange(state.walletState, state.blockchainState)
        updateTransactions(state.transactionsState.transactions)
        updateInitialHeight(state.blockchainState)
        
        walletNameView.title = state.walletState.name
        walletNameView.subtitle = state.walletState.subaddress?.label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedTransactions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = transactionsKeys[section]
        return sortedTransactions[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let key = transactionsKeys[section]
        let dateFormatter = DateFormatter()
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: tableView.frame.size.width, height: 45)))
        let date = NSCalendar.current.date(from: key)!
        label.backgroundColor = UIColor(red: 249, green: 250, blue: 252)
        label.textColor = UIColor(hex: 0x9BACC5)
        label.font = UIFont(name: "Lato-SemiBold", size: 14.0)
        label.textAlignment = .center
        
        if Calendar.current.isDateInToday(date) {
            label.text = "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            label.text = "Yesterday"
        } else {
            let now = Date()
            let currentYear = Calendar.current.component(.year, from: now)
            dateFormatter.dateFormat = key.year == currentYear ? "dd MMMM" : "dd MMMM yyyy"
            label.text = dateFormatter.string(from: date)
        }
        
        return label
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let transaction = getTransaction(by: indexPath) else {
            return UITableViewCell()
        }
        
        return tableView.dequeueReusableCell(withItem: transaction, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let transaction = getTransaction(by: indexPath) {
            presentTransactionDetails(for: transaction)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y > contentView.cardView.frame.height else {
            contentView.shortStatusBarView.isHidden = true
            updateCryptoBalance(store.state.balanceState.balance)
            updateFiatBalance(store.state.balanceState.unlockedFiatBalance)
            return
        }

        contentView.shortStatusBarView.isHidden = false
        updateCryptoBalance(store.state.balanceState.balance)
        updateFiatBalance(store.state.balanceState.unlockedFiatBalance)
        contentView.shortStatusBarView.receiveButton.flex.markDirty()
        contentView.shortStatusBarView.sendButton.flex.markDirty()
        contentView.shortStatusBarView.flex.layout()
    }
    
    @objc
    private func presentWalletActions() {
        let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
        
        let presentReconnectAction = UIAlertAction(title: NSLocalizedString("reconnect", comment: ""), style: .default) { [weak self] _ in
            self?.reconnectAction()
        }
        
        let presentSubaddressesAction = UIAlertAction(title: NSLocalizedString("subaddresses", comment: ""), style: .default) { [weak self] _ in
            self?.dashboardFlow?.change(route: .subaddresses)
        }
        
        alertViewController.addAction(presentReconnectAction)
        alertViewController.addAction(presentSubaddressesAction)
        alertViewController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertViewController, animated: true)
        }
    }
    
    @objc
    private func changeShownBalance() {
        showAbleBalance = !showAbleBalance
        onStateChange(store.state)
    }
    
    private func getTransaction(by indexPath: IndexPath) -> TransactionDescription? {
        let key = transactionsKeys[indexPath.section]
        return sortedTransactions[key]?[indexPath.row]
    }

    private func onWalletChange(_ walletState: WalletState, _ blockchainState: BlockchainState) {
        initialHeight = 0
        updateTitle(walletState.name)
    }
    
    private func reconnectAction() {
        let alertController = UIAlertController(
            title: NSLocalizedString("reconnection", comment: ""),
            message: NSLocalizedString("reconnect_alert_text", comment: ""),
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(
            title: NSLocalizedString("reconnect", comment: ""),
            style: .default,
            handler: { [weak self, weak alertController] _ in
                self?.store.dispatch(WalletActions.reconnect)
                alertController?.dismiss(animated: true)
            }
        ))
        
        alertController.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: nil
        ))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func observePullAction(for offset: CGFloat) {
        guard offset < -40 else {
            return
        }
        
        store.dispatch(TransactionsActions.forceUpdateTransactions)
    }
    
    private func updateInitialHeight(_ blockchainState: BlockchainState) {
        guard initialHeight == 0 else {
            return
        }
        
        if case let .syncing(height) = blockchainState.connectionStatus {
            initialHeight = height
        }
    }
    
    @objc
    private func presentWalletsList() {
        dashboardFlow?.change(route: .wallets)
    }
    
    @objc
    private func presentReceive() {
        dashboardFlow?.change(route: .receive)
    }
    
    @objc
    private func presentSend() {
        dashboardFlow?.change(route: .send)
    }
    
    private func presentTransactionDetails(for tx: TransactionDescription) {
        let transactionDetailsViewController = TransactionDetailsViewController(transactionDescription: tx)
        let nav = UINavigationController(rootViewController: transactionDetailsViewController)
        nav.modalPresentationStyle = .custom
        tabBarController?.presentWithBlur(nav, animated: true)
    }
    
    private func updateSyncing(_ currentHeight: UInt64, blockchainHeight: UInt64) {
        if blockchainHeight < currentHeight || blockchainHeight == 0 {
            store.dispatch(BlockchainActions.fetchBlockchainHeight)
        } else {
            let track = blockchainHeight - initialHeight
            let _currentHeight = currentHeight > initialHeight ? currentHeight - initialHeight : 0
            let remaining = track > _currentHeight ? track - _currentHeight : 0
            guard currentHeight != 0 && track != 0 else { return }
            let val = Float(_currentHeight) / Float(track)
            let prg = Int(val * 100)
            contentView.progressBar.updateProgress(prg)
            contentView.updateStatus(text: NSLocalizedString("blocks_remaining", comment: "")
                + ": "
                + String(remaining)
                + "(\(prg)%)")
        }
    }
    
    private func updateStatus(_ connectionStatus: ConnectionStatus) {
        switch connectionStatus {
        case let .syncing(currentHeight):
            updateSyncing(currentHeight, blockchainHeight: store.state.blockchainState.blockchainHeight)
        case .connection:
            updateStatusConnection()
        case .notConnected:
            updateStatusNotConnected()
        case .startingSync:
            updateStatusstartingSync()
        case .synced:
            updateStatusSynced()
        case .failed:
            updateStatusFailed()
        }
    }
    
    private func updateStatusConnection() {
        contentView.progressBar.updateProgress(0)
        contentView.updateStatus(text: NSLocalizedString("connecting", comment: ""))
        contentView.hideSyncingIcon()
    }
    
    private func updateStatusNotConnected() {
        contentView.progressBar.updateProgress(0)
        contentView.updateStatus(text: NSLocalizedString("not_connected", comment: ""))
        contentView.hideSyncingIcon()
    }
    
    private func updateStatusstartingSync() {
        contentView.progressBar.updateProgress(0)
        contentView.updateStatus(text: NSLocalizedString("starting_sync", comment: ""))
        contentView.hideSyncingIcon()
        contentView.rootFlexContainer.flex.layout()
    }
    
    private func updateStatusSynced() {
        contentView.progressBar.updateProgress(100)
        contentView.updateStatus(text: NSLocalizedString("synchronized", comment: ""))
        contentView.hideSyncingIcon()
    }
    
    private func updateStatusFailed() {
        contentView.progressBar.updateProgress(0)
        contentView.updateStatus(text: NSLocalizedString("failed_connection_to_node", comment: ""))
        contentView.hideSyncingIcon()
    }
    
    private func updateFiatBalance(_ amount: Amount) {
        guard contentView.shortStatusBarView.isHidden else {
            updateShortFiatBalance(amount)
            return
        }
        
        contentView.fiatAmountLabel.text = amount.formatted()
        contentView.fiatAmountLabel.flex.markDirty()
    }
    
    private func updateCryptoBalance(_ amount: Amount) {
        guard contentView.shortStatusBarView.isHidden else {
            updateShortCryptoBalance(amount)
            return
        }
        
        contentView.cryptoTitleLabel.text = "XMR"
            + " "
            + (showAbleBalance ? NSLocalizedString("available_balance", comment: "") : NSLocalizedString("full_balance", comment: ""))
        contentView.cryptoAmountLabel.text = amount.formatted()
        contentView.cryptoTitleLabel.flex.markDirty()
        contentView.cryptoAmountLabel.flex.markDirty()
    }
    
    private func updateShortCryptoBalance(_ amount: Amount) {
        contentView.shortStatusBarView.cryptoAmountLabel.text = amount.formatted()
        contentView.shortStatusBarView.cryptoAmountLabel.flex.markDirty()
    }
    
    private func updateShortFiatBalance(_ amount: Amount) {
        contentView.shortStatusBarView.fiatAmountLabel.text = amount.formatted()
        contentView.shortStatusBarView.fiatAmountLabel.flex.markDirty()
    }
    
    private func updateTransactions(_ transactions: [TransactionDescription]) {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }

        contentView.transactionTitleLabel.isHidden = transactions.count <= 0
        
        let sortedTransactions = Dictionary(grouping: transactions) {
            return Calendar.current.dateComponents([.day, .year, .month], from: ($0.date))
        }

        guard self.transactions != transactions else {
            return
        }
        
        self.transactions = transactions
        self.sortedTransactions = sortedTransactions
        
        if self.transactions.count > 0 {
            if contentView.transactionTitleLabel.isHidden {
                contentView.transactionTitleLabel.isHidden = false
            }
        } else if !contentView.transactionTitleLabel.isHidden {
            contentView.transactionTitleLabel.isHidden = true
        }
        
        contentView.transactionsTableView.reloadData()
    }
    
    private func updateTitle(_ title: String) {
        if navigationItem.leftBarButtonItem?.title != title {
            navigationItem.leftBarButtonItem?.title = title
        }
    }

    @objc
    private func toAddressBookAction() {
        dashboardFlow?.change(route: .addressBook)
    }
    
    @objc
    private func refresh(_ refreshControl: UIRefreshControl) {
        store.dispatch(TransactionsActions.forceUpdateTransactions)
        refreshControl.endRefreshing()
    }
}
