import Foundation

private(set) var handlers: [AnyHandler] = []

public func register(handler: AnyHandler) {
    handlers.append(handler)
}
