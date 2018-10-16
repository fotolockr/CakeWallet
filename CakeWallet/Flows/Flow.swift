import UIKit

protocol Flow {
    associatedtype Route
    var rootController: UIViewController { get }
    func change(route: Route)
}
