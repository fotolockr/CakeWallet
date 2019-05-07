import CakeWalletLib
import CakeWalletCore
import CWMonero

public enum WalletStage {
    case none, isChanging, changed
}

public struct WalletState: StateType {
    public enum Action: AnyAction {
        case changedName(String)
        case changedAddress(String)
        case changedSeed(String)
        case changedIsWatchOnly(Bool)
        case reseted(String, String, String, Bool, WalletType, WalletKeys, Subaddress?)
        case created(Wallet)
        case inited(Wallet)
        case loaded(Wallet)
        case restored(Wallet)
        case fetchedWalletKeys(WalletKeys)
        case changedWalletStage(WalletStage)
        case changedSubaddress(Subaddress?)
        case changeAccount(Account)
    }
    
    public let name: String
    public let address: String
    public let seed: String
    public let isWatchOnly: Bool
    public let walletType: WalletType
    public let walletKeys: WalletKeys?
    public let stage: WalletStage
    public let subaddress: Subaddress?
    public let account: Account
    
    public init(
        name: String,
        address: String,
        seed: String,
        isWatchOnly: Bool,
        walletType: WalletType,
        walletKeys: WalletKeys? = nil,
        stage: WalletStage = .none,
        subaddress: Subaddress?,
        account: Account) {
        self.name = name
        self.address = address
        self.seed = seed
        self.isWatchOnly = isWatchOnly
        self.walletType = walletType
        self.walletKeys = walletKeys
        self.stage = stage
        self.subaddress = subaddress
        self.account = account
    }
    
    public func reduce(_ action: Action) -> WalletState {
        switch action {
        case let .changedName(name):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage, subaddress: subaddress, account: account)
        case let .changedAddress(address):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage, subaddress: subaddress, account: account)
        case let .changedSeed(seed):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage, subaddress: subaddress, account: account)
        case let .changedIsWatchOnly(isWatchOnly):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage, subaddress: subaddress, account: account)
        case let .reseted(name, address, seed, isWatchOnly, walletType, walletKeys, subaddress):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage, subaddress: subaddress, account: account)
        case let .created(wallet):
            return WalletState(name: wallet.name, address: wallet.address, seed: wallet.seed, isWatchOnly: wallet.isWatchOnly, walletType: type(of: wallet).walletType, walletKeys: wallet.keys, stage: .changed, subaddress: nil, account: account)
        case let .loaded(wallet):
            return WalletState(name: wallet.name, address: wallet.address, seed: wallet.seed, isWatchOnly: wallet.isWatchOnly, walletType: type(of: wallet).walletType, walletKeys: wallet.keys, stage: .changed, subaddress: nil, account: account)
        case let .restored(wallet):
            return WalletState(name: wallet.name, address: wallet.address, seed: wallet.seed, isWatchOnly: wallet.isWatchOnly, walletType: type(of: wallet).walletType, walletKeys: wallet.keys, stage: .changed, subaddress: nil, account: account)
        case let .fetchedWalletKeys(walletKeys):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: .changed, subaddress: subaddress, account: account)
        case let .changedWalletStage(stage):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage, subaddress: subaddress, account: account)
        case let .inited(wallet):
            return WalletState(name: wallet.name, address: wallet.address, seed: wallet.seed, isWatchOnly: wallet.isWatchOnly, walletType: type(of: wallet).walletType, walletKeys: wallet.keys, stage: .changed, subaddress: subaddress, account: account)
        case let .changedSubaddress(subaddress):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage, subaddress: subaddress, account: account)
        case let .changeAccount(account):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage, subaddress: subaddress, account: account)
        }
    }
    
    public static func ==(lhs: WalletState, rhs: WalletState) -> Bool {
        return lhs.name == rhs.name
            && lhs.address == rhs.address
            && lhs.seed == rhs.seed
            && lhs.isWatchOnly == rhs.isWatchOnly
    }
}
