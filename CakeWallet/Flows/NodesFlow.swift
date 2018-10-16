import UIKit
import CakeWalletLib

final class NodesFlow: Flow {
    enum Route {
        case start
        case new
    }
    
    var rootController: UIViewController {
        return navigationController
    }
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        let nodesViewController = NodesViewController(store: store, nodesFlow: nil)
        self.navigationController = navigationController
        nodesViewController.nodesFlow = self
    }
    
    func change(route: NodesFlow.Route) {
        switch route {
        case .start:
            // fime: need to generate this to another function
            if
                let nodesViewController = navigationController.viewControllers.reduce(nil, { (nodesViewController, viewController) -> NodesViewController? in
                    if let _nodesViewController = viewController as? NodesViewController {
                        return _nodesViewController
                    }
                    
                    return nil
                }) {
                navigationController.popToViewController(nodesViewController, animated: true)
                return
            }
            
            navigationController.pushViewController(NodesViewController(store: store, nodesFlow: self), animated: true)
        case .new:
            let newNodeViewController = NewNodeViewController(nodesList: NodesList.shared)
            navigationController.pushViewController(newNodeViewController, animated: true)
        }
    }
}
