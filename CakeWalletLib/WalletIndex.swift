import Foundation

public struct WalletIndex {
    public let name: String
    public let type: WalletType
    
    public init(name: String, type: WalletType) {
        self.name = name
        self.type = type
    }
}

extension WalletIndex: Equatable {
    public static func == (lhs: WalletIndex, rhs: WalletIndex) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
}
