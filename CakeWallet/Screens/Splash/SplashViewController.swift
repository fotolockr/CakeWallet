import Foundation
import UIKit
import CakeWalletLib
import CakeWalletCore

final class SplashViewController: BaseViewController<SplashView>, StoreSubscriber {
    private var store: Store<ApplicationState>?
    var handler: (() -> Void)?
    
    init(store: Store<ApplicationState>?) {
        self.store = store
        super.init()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if let handler = handler {
            handler()
        }
    }
    
    func onStateChange(_ state: WalletState) {
        
    }
}
