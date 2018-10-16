import Foundation

public protocol AnyEffect {
    func anyEffect(_ store: AnyStore, action: AnyAction) -> AnyAction?
}
