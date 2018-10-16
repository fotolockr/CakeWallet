import Foundation

public enum Result<T> {
    case success(T), failed(Error)
}
