import CakeWalletLib
import CWMonero

extension TransactionDescription {
    func subaddresses() -> [Subaddress] {
        guard let moneroWallet = currentWallet as? MoneroWallet else {
            return []
        }
        
        return moneroWallet.subaddresses().get(by: addressIndecies)
    }
}
