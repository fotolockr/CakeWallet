import Foundation

public protocol NodeDescription {
    var uri: String { get }
    var login: String { get }
    var password: String { get }
    func isAble(_ handler: @escaping (Bool) -> Void)
}

extension NodeDescription {
    public func compare(with aNode: NodeDescription) -> Bool {
        return self.uri == aNode.uri
            && self.login == aNode.login
            && self.password == aNode.password
    }
}
