import CakeWalletCore
import CakeWalletLib
import CWMonero

public typealias ExchangeRate = [CryptoCurrency: [CryptoCurrency: Double]]

public struct ExchangeState: StateType {
    public static func == (lhs: ExchangeState, rhs: ExchangeState) -> Bool {
        return lhs.trade == rhs.trade
            && lhs.rates == rhs.rates
    }
    
    public enum Action: AnyAction {
        case changeRateOnlyFor(CryptoCurrency, CryptoCurrency, Double)
        case changedRate(ExchangeRate)
        case changedTrade(ExchangeTrade?)
    }
    
    public let trade: ExchangeTrade?
    public let rates: ExchangeRate
    
    public init(trade: ExchangeTrade?, rates: ExchangeRate = ExchangeRate()) {
        self.trade = trade
        self.rates = rates
    }
    
    public func reduce(_ action: ExchangeState.Action) -> ExchangeState {
        switch action {
        case let .changedRate(rates):
            return ExchangeState(trade: trade, rates: rates)
        case let .changedTrade(trade):
            return ExchangeState(trade: trade, rates: rates)
        case let .changeRateOnlyFor(main, pair, price):
            var rates = self.rates
            
            if rates[main] == nil {
                rates[main] = [pair: price]
            } else {
                rates[main]?[pair] = price
            }
            
            return ExchangeState(trade: trade, rates: rates)
        }
    }
}
