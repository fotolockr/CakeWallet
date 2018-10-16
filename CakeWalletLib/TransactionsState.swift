import Foundation

public enum SendingStage: Equatable {
    public static func == (lhs: SendingStage, rhs: SendingStage) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.creating, .creating):
            return true
        case (let .pendingTransaction(ltx), let .pendingTransaction(rtx)):
            return ltx.description == rtx.description
        case (.commited, .commited):
            return true
        default:
            return false
        }
    }
    
    case none
    case creating
    case pendingTransaction(PendingTransaction)
    case commiting
    case commited
}
