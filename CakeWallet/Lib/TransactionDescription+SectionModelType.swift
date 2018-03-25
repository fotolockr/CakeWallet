//
//  TransactionDescription+SectionModelType.swift
//  Wallet
//
//  Created by Cake Technologies 12/1/17.
//  Copyright © 2017 Cake Technologies. 
//

import Foundation

extension Array where Element == TransactionDescription {
    struct SectionOfTransactions: Equatable {
        static func ==(lhs: Array<TransactionDescription>.SectionOfTransactions, rhs: Array<TransactionDescription>.SectionOfTransactions) -> Bool {
            return lhs.items == rhs.items
        }
        
        var date: Date
        var items: [Element]
        
        init(original: Array<TransactionDescription>.SectionOfTransactions, items: [TransactionDescription]) {
            self = original
            self.items = items
        }
        
        init(date: Date, items: [TransactionDescription]) {
            self.date = date
            self.items = items
        }
    }
    
    func toDatesSections() -> [SectionOfTransactions] {
        var sections = [SectionOfTransactions]()
        
        self.forEach { tx in
            for i in 0..<sections.count {
                if Calendar.current.isDate(sections[i].date, inSameDayAs: tx.date) {
                    sections[i].items.append(tx)
                    return
                }
            }
            
            sections.append(SectionOfTransactions(date: tx.date, items: [tx]))
        }
        
        return sections.map { section in
            return SectionOfTransactions(
                date: section.date,
                items: section.items.sorted(by: { $0.date > $1.date }))
        }.sorted(by: { $0.date > $1.date })
    }
}
