import Foundation

public enum ConnectionStatus {
    case notConnected
    case connection
    case startingSync
    case syncing(UInt64)
    case synced
    case failed
}

extension ConnectionStatus: Equatable {
    public static func == (lhs: ConnectionStatus, rhs: ConnectionStatus) -> Bool {
        switch (lhs, rhs) {
        case (.notConnected, .notConnected):
            return true
        case (.connection, .connection):
            return true
        case (.startingSync, .startingSync):
            return true
        case let (.syncing(l), .syncing(r)):
            return l == r
        case (.synced, .synced):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
