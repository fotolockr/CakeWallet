import Foundation
import CakeWalletLib

final class ExchangeList {
    static var providers: [ExchangeProvider] {
        return exchangesTypes.map { $0.provider }
    }
    static let exchangesTypes = [XMRTOExchange.self, ChangeNowExchange.self, MorphExchange.self] as [AnyExchange.Type]
    
    func exchange(for pair: Pair) -> AnyExchange? {
        guard let provider = ExchangeList.exchangesTypes.filter({ $0.pairs.contains(pair) }).first?.provider else {
            return nil
        }
        
        return exchange(for: provider)
    }
    
    func exchangeProviders(for pair: Pair) -> [ExchangeProvider] {
        return ExchangeList.providers.reduce([]) { acc, e -> [ExchangeProvider] in
            var acc = acc
            ExchangeList.providers.map({ (provider: $0, pairs: self.pairs(for: $0)) })
                .map({ res -> ExchangeProvider? in res.pairs.contains(pair) ? res.provider : nil })
                .compactMap({ $0 })
                .forEach({ !acc.contains($0) ? acc.append($0) : () })
            return acc
        }
    }
    
    func exchanges(for pair: Pair) -> [AnyExchange] {
        return ExchangeList.exchangesTypes.map { (provider: $0.provider, pairs: $0.pairs) }
            .filter { $0.pairs.contains(pair) }
            .map { $0.provider }
            .compactMap { $0 }
            .map { self.exchange(for: $0) }
            .compactMap { $0 }
    }
    
    func exchange(for provider: ExchangeProvider) -> AnyExchange? {
        switch provider {
        case .changenow:
            return ChangeNowExchange()
        case .morph:
            return MorphExchange()
        case .xmrto:
            return XMRTOExchange()
        }
    }
    
    private func pairs(for provider: ExchangeProvider) -> [Pair] {
        switch provider {
        case .changenow:
            return ChangeNowExchange.pairs
        case .xmrto:
            return XMRTOExchange.pairs
        case .morph:
            return MorphExchange.pairs
        }
    }
}
