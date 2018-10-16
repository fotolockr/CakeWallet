import CakeWalletLib
import CakeWalletCore

public enum WalletStage {
    case none, isChanging, changed
}

public struct WalletState: StateType {
    public enum Action: AnyAction {
        case changedName(String)
        case changedAddress(String)
        case changedSeed(String)
        case changedIsWatchOnly(Bool)
        case reseted(String, String, String, Bool, WalletType, WalletKeys)
        case created(Wallet)
        case loaded(Wallet)
        case restored(Wallet)
        case fetchedWalletKeys(WalletKeys)
        case changedWalletStage(WalletStage)
    }
    
    public let name: String
    public let address: String
    public let seed: String
    public let isWatchOnly: Bool
    public let walletType: WalletType
    public let walletKeys: WalletKeys?
    public let stage: WalletStage
    
    public init(
        name: String,
        address: String,
        seed: String,
        isWatchOnly: Bool,
        walletType: WalletType,
        walletKeys: WalletKeys? = nil,
        stage: WalletStage = .none) {
        self.name = name
        self.address = address
        self.seed = seed
        self.isWatchOnly = isWatchOnly
        self.walletType = walletType
        self.walletKeys = walletKeys
        self.stage = stage
    }
    
    public func reduce(_ action: Action) -> WalletState {
        switch action {
        case let .changedName(name):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage)
        case let .changedAddress(address):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage)
        case let .changedSeed(seed):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage)
        case let .changedIsWatchOnly(isWatchOnly):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage)
        case let .reseted(name, address, seed, isWatchOnly, walletType, walletKeys):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage)
        case let .created(wallet):
            return WalletState(name: wallet.name, address: wallet.address, seed: wallet.seed, isWatchOnly: wallet.isWatchOnly, walletType: type(of: wallet).walletType, walletKeys: wallet.keys, stage: .changed)
        case let .loaded(wallet):
            return WalletState(name: wallet.name, address: wallet.address, seed: wallet.seed, isWatchOnly: wallet.isWatchOnly, walletType: type(of: wallet).walletType, walletKeys: wallet.keys, stage: .changed)
        case let .restored(wallet):
            return WalletState(name: wallet.name, address: wallet.address, seed: wallet.seed, isWatchOnly: wallet.isWatchOnly, walletType: type(of: wallet).walletType, walletKeys: wallet.keys, stage: .changed)
        case let .fetchedWalletKeys(walletKeys):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: .changed)
        case let .changedWalletStage(stage):
            return WalletState(name: name, address: address, seed: seed, isWatchOnly: isWatchOnly, walletType: walletType, walletKeys: walletKeys, stage: stage)
        }
    }
    
    public static func ==(lhs: WalletState, rhs: WalletState) -> Bool {
        return lhs.name == rhs.name
            && lhs.address == rhs.address
            && lhs.seed == rhs.seed
            && lhs.isWatchOnly == rhs.isWatchOnly
    }
}
