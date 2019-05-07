import Foundation

struct TransactionDetailsCellItem: CellItem {
    let row: TransactionDetailsRows
    let value: String
    
    func setup(cell: TransactionDetailsCell) {
        cell.configure(title: row.string() + ":", value: value)
    }
}
