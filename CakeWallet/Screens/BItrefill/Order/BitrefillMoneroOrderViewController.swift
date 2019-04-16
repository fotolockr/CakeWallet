import UIKit
import QRCode
import Alamofire
import SwiftyJSON
import CakeWalletCore


final class BitrefillMoneroOrderViewController: BaseViewController<BitrefillMoneroOrderView> {
    let store: Store<ApplicationState>
    let trade: ExchangeTrade
    
    init(store: Store<ApplicationState>, trade: ExchangeTrade) {
        self.store = store
        self.trade = trade
        
        super.init()
    }
    
    override func configureBinds() {
        super.configureBinds()
        
        // show tradeID and common info about actual process
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendTransaction()
    }
    
    private func sendTransaction() {
        // contentView.activityIndicater.start
        
        store.dispatch(
            WalletActions.send(
                amount: trade.value,
                toAddres: trade.inputAddress,
                paymentID: "",
                priority: store.state.settingsState.transactionPriority,
                handler: { [weak self] result in
                    switch result {
                    case let .success(pendingTransaction):
                        self?.store.dispatch(
                            WalletActions.commit(
                                transaction: pendingTransaction,
                                handler: { result in
                                    switch result {
                                    case .success(_):
                                        print("SUCCESS of commiting transaction")
                                        // try? ExchangeTransactions.shared.add()
                                    case let .failed(error):
                                        print("Error", error)
                                    }
                                }
                            )
                        )
                        
                    case let .failed(error):
                        self?.showErrorAlert(error: error)
                        break
                    }
                }
            )
        )
    }
}
