import UIKit
import FlexLayout
import CakeWalletLib
import CakeWalletCore

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
        
//        NotificationCenter.default.addObserver(forName: Notification.Name("changeTheme"), object: nil, queue: nil) { [weak self] notification in
//            guard let theme = notification.object as? Theme else {
//                return
//            }
//            
////            UserDefaults.standard.set(theme.rawValue, forKey: Configurations.DefaultsKeys.currentTheme)
//            Theme.applyTheme(theme: theme)
//            self?.contentView.setNeedsDisplay()
//            self?.contentView.setNeedsLayout()
//        }
    }
    
    override func loadView() {
        super.loadView()
        view = View()
        configureBinds()
        setTitle()
    }
    
    func setTitle() {}
}
