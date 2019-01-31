import CakeWalletLib
import CWMonero

func getTransactionKey(for transactionId: String) -> String? {
    guard let moneroWallet = currentWallet as? MoneroWallet else {
        return nil
    }
    
    return moneroWallet.getTransactionKey(for: transactionId)
}
