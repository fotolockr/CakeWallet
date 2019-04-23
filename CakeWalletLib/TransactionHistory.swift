import Foundation

public enum TransactionPriority: Formatted {
    case slow, `default`, fast, fastest
    
    public var rawValue: UInt64 {
        switch self {
        case .slow:
            return 1
        case .default:
            return 2
        case .fast:
            return 3
        case .fastest:
            return 4
        }
    }
    
    public init?(rawValue: UInt64) {
        switch rawValue {
        case 1:
            self = .slow
        case 2:
            self = .default
        case 3:
            self = .fast
        case 4:
            self = .fastest
        default:
            return nil
        }
    }
    
    public init?(rawValue: Int) {
        if rawValue > 0 && rawValue <= 4 {
            self.init(rawValue: UInt64(rawValue))
        } else {
            return nil
        }
    }
    
    public func formatted() -> String {
        let description: String
        
        switch self {
        case .slow:
            description = "Slow"
        case .default:
            description = "Regular"
        case .fast:
            description = "Fast"
        case .fastest:
            description = "Fastest"
        }
        
        return description
    }
}

public enum TransactionDirection {
    case incoming, outcoming
}

public enum TransactionStatus: Equatable {
    case ok
    case pending
    case error(String)
}

public struct TransactionDescription {
    public let id: String
    public let date: Date
    public let totalAmount: Amount
    public let fee: Amount
    public let direction: TransactionDirection
    public let priority: TransactionPriority
    public let status: TransactionStatus
    public let isPending: Bool
    public let height: UInt64
    public let paymentId: String
    public let accountIndex: UInt32
    
    public init(
        id: String,
        date: Date,
        totalAmount: Amount,
        fee: Amount,
        direction: TransactionDirection,
        priority: TransactionPriority,
        status: TransactionStatus,
        isPending: Bool,
        height: UInt64,
        paymentId: String,
        accountIndex: UInt32) {
        self.id = id
        self.date = date
        self.totalAmount = totalAmount
        self.fee = fee
        self.direction = direction
        self.priority = priority
        self.status = status
        self.isPending = isPending
        self.height = height
        self.paymentId = paymentId
        self.accountIndex = accountIndex
    }
}

extension TransactionDescription: Equatable {
    public static func ==(lhs: TransactionDescription, rhs: TransactionDescription) -> Bool {
        return lhs.id == rhs.id
            && lhs.status == rhs.status
            && lhs.isPending == rhs.isPending
            && lhs.date == rhs.date
    }
}


public protocol TransactionHistory {
    var count: Int { get }
    var transactions: [TransactionDescription] { get }
    
    func newTransactions(afterIndex index: Int) -> [TransactionDescription]
    func refresh()
}

