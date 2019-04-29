import UIKit
import FlexLayout
import CakeWalletLib
import CakeWalletCore
import VisualEffectView

class BaseViewController<View: BaseView>: AnyBaseViewController {
    var contentView: View { return view as! View }
    
    override init() {
        super.init()
        setTitle()
        
        NotificationCenter.default.addObserver(forName: Notification.Name("langChanged"), object: nil, queue: nil) { [weak self] notification in
            self?.loadView()
            
            if let title = self?.title {
                self?.title = title
            }
            
            if let storeSub = self as? AnyStoreSubscriber {
                storeSub._onStateChange(store.state)
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        view = View()
        configureBinds()
        setTitle()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let navController = self.navigationController else {
            return
        }
 
        navController.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: applyFont(ofSize: 16)]
    }
    
    func setTitle() {}
}
