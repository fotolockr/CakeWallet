import CakeWalletLib

public struct MoneroWalletKeys: WalletKeys {
    public let spendKey: MoneroWalletKeysPair
    public let viewKey: MoneroWalletKeysPair
    
    public init(spendKey: MoneroWalletKeysPair, viewKey: MoneroWalletKeysPair) {
        self.spendKey = spendKey
        self.viewKey = viewKey
    }
}
