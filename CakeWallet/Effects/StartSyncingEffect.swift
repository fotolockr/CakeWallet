import Foundation
import CakeWalletLib
import CakeWalletCore
import SwiftyJSON
import Alamofire

public final class startingSyncEffect: Effect {
    public init() {}
    public func effect(_ store: Store<ApplicationState>, action: BlockchainState.Action) -> AnyAction? {
        if
            case let .changedConnectionStatus(status) = action,
            case .connection = status {
            workQueue.async {
                store.dispatch(BlockchainState.Action.changedConnectionStatus(.startingSync))
                currentWallet.startUpdate()
            }
        }
        
        return action
    }
}


let ratesUpdateQueue = DispatchQueue(label: "app.cakewallet.rates-update-queue", qos: .utility, attributes: DispatchQueue.Attributes.concurrent)

public final class ChangeFiatPriceEffect: Effect {
    public init() {}
    public func effect(_ store: Store<ApplicationState>, action: BalanceState.Action) -> AnyAction? {
        guard case .changedUnlockedBalance = action else {
            return action
        }
        
        store.dispatch(
            BalanceActions.updateFiatPrice(currency: store.state.settingsState.fiatCurrency)
        )
        
        return action
    }
}

public final class UpdateFiatPriceAfterFiatChangeEffect: Effect {
    public init() {}
    public func effect(_ store: Store<ApplicationState>, action: SettingsState.Action) -> AnyAction? {
        guard case let .changedFiatCurrency(currency) = action else {
            return action
        }
        
        store.dispatch(
            BalanceActions.updateFiatPrice(currency: currency)
        )
        
        return action
    }
}

public final class UpdateFiatBalanceAfterPriceChangeEffect: Effect {
    public init() {}
    public func effect(_ store: Store<ApplicationState>, action: BalanceState.Action) -> AnyAction? {
        guard case let .changedPrice(price) = action else {
            return action
        }
        
        store.dispatch(
            BalanceActions.updateFiatBalance(price: price)
        )
        
        return action
    }
}
