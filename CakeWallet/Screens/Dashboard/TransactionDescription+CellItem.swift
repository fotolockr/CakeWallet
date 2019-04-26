import Foundation
import CakeWalletLib

extension TransactionDescription: CellItem {
    func setup(cell: TransactionUITableViewCell) {
        let price = store.state.balanceState.price
        let currency = store.state.settingsState.fiatCurrency
        let fiatAmount = calculateFiatAmount(currency, price: price, balance: totalAmount)
        cell.configure(direction: direction, date: date, isPending: isPending, cryptoAmount: totalAmount, fiatAmount: fiatAmount.formatted())
    }
}
