import Foundation

public struct MoneroWalletKeysPair {
    public let pub: String
    public let sec: String
    
    public init(pub: String, sec: String) {
        self.pub = pub
        self.sec = sec
    }
}
