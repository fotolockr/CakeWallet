import Foundation
import CakeWalletLib
import CakeWalletCore
import SwiftyJSON
import Alamofire

func updateFiatPrice(for crypto: Currency, to fiatCurrency: FiatCurrency, handler: @escaping (Double) -> Void) {
    guard fiatCurrency != .vef else { // fixme: need to define function above this to call only updateFiatPrice OR updateFiatPriceForVef. And someone kill me please need to extend this.
        updateFiatPriceForVef(for: crypto, handler: handler)
        return
    }
        
    var url =  URLComponents(string: "https://api.coinmarketcap.com/v2/ticker/")!
    url.queryItems = [
        URLQueryItem(name: "structure", value: "array"),
        URLQueryItem(name: "convert", value: fiatCurrency.formatted())
    ]
    Alamofire.request(url, method: .get).responseData(queue: ratesUpdateQueue, completionHandler: { response in
        guard let data = response.data else {
            return
        }
        
        let json = JSON(data)

        guard let results = json["data"].array else {
            return
        }

        let price = results.reduce(0.0, { price, json -> Double in
            if
                json["symbol"].stringValue == crypto.formatted(),
                let price = json["quotes"][fiatCurrency.formatted()]["price"].double {
                return price
            }
            
            return price
        })
        
        handler(price)
    })
}

func updateFiatPriceForVef(for crypto: Currency, baseCrypto: CryptoCurrency = CryptoCurrency.bitcoin, handler: @escaping (Double) -> Void) {
    var url =  URLComponents(string: "https://api.coinmarketcap.com/v2/ticker/")!
    url.queryItems = [
        URLQueryItem(name: "structure", value: "array"),
        URLQueryItem(name: "convert", value: baseCrypto.formatted())
    ]
    Alamofire.request(url, method: .get).responseData(queue: ratesUpdateQueue, completionHandler: { response in
        guard let data = response.data else {
            return
        }
        
        let json = JSON(data)

        guard let results = json["data"].array else {
            return
        }
        
        let price = results.reduce(0.0, { price, json -> Double in
            if
                json["symbol"].stringValue == crypto.formatted(),
                let price = json["quotes"][baseCrypto.formatted()]["price"].double {
                return price
            }
            
            return price
        })
        
        fetchBitcoinPriceForVef() { result in
            switch result {
            case let .success(vefPrice):
                let resultPrice = price * vefPrice
                handler(resultPrice)
            case .failed(_):
                break
            }
        }
    })
}

private func fetchBitcoinPriceForVef(_ amount: Int = 1, handler: @escaping (CakeWalletLib.Result<Double>) -> Void) {
    var url =  URLComponents(string: "https://api.bitcoinvenezuela.com/")!
    url.queryItems = [
        URLQueryItem(name: "html", value: "no"),
        URLQueryItem(name: "currency", value: CryptoCurrency.bitcoin.formatted()),
        URLQueryItem(name: "amount", value: String(amount)),
        URLQueryItem(name: "to", value: FiatCurrency.vef.formatted())
    ]
    Alamofire.request(url, method: .get).responseData(queue: ratesUpdateQueue, completionHandler: { response in
        guard let data = response.data else {
            return
        }
        
        guard
            let priceString = String(data: data, encoding: .utf8),
            let price = Double(priceString) else {
                //                handler(.failed()) // fixme: need error for this
                return
        }
        
        handler(.success(price))
    })
}

func calculateFiatAmount(_ currency: FiatCurrency, price: Double, balance: Amount) -> Amount {
    guard let balance = Double(balance.formatted()) else {
        return FiatAmount(from: "0.0", currency: currency)
    }
    
    let fiatBalance = balance * price
    return FiatAmount(from: String(format: "%f", fiatBalance), currency: currency)
}

public struct UpdateFiatPriceHandler: AsyncHandler {
    public func handle(action: BalanceActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case let .updateFiatPrice(fiatCurrency) = action else { return }
        
        workQueue.async {
            let currency = store.state.balanceState.balance.currency
            updateFiatPrice(for: currency, to: fiatCurrency, handler: { price in
                handler(BalanceState.Action.changedPrice(price))
            })
        }
    }
}

public struct UpdateFiatBalanceHandler: AsyncHandler {
    public func handle(action: BalanceActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case let .updateFiatBalance(price) = action else { return }
        let unlockedBalance = store.state.balanceState.unlockedBalance
        let fullBalance = store.state.balanceState.balance
        let fiatCurrency = store.state.settingsState.fiatCurrency
        let unlockedAmount = calculateFiatAmount(fiatCurrency, price: price, balance: unlockedBalance)
        let fullBalanceFiatAmount = calculateFiatAmount(fiatCurrency, price: price, balance: fullBalance)
        
        handler(
            BalanceState.Action.changedUnlockedFiatBalance(unlockedAmount)
        )
        
        handler(
            BalanceState.Action.changedFullFiatBalance(fullBalanceFiatAmount)
        )
    }
}
