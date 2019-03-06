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
    }
    
    override func loadView() {
        super.loadView()
        view = View()
        configureBinds()
        setTitle()
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        guard let navController = self.navigationController else {
//            return
//        }
//        
//        let leftButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 40))
//        let leftButton = UIButton(type: .system)
//        
//        leftButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 25, bottom: 0, right: 20)
//        
//        leftButton.frame = leftButtonView.frame
//        leftButton.setImage(UIImage.init(named: "arrow_right"), for: .normal)
//        leftButton.setTitle("", for: .normal)
//        leftButton.autoresizesSubviews = true
//        leftButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        leftButtonView.addSubview(leftButton)
//        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
//        view.backgroundColor = .yellow
//        let leftBarButton = UIBarButtonItem(customView: view)
//        
//        self.navigationItem.backBarButtonItem = leftBarButton
////        self.navigationItem.leftBarButtonItem = leftBarButton
//        navController.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Lato-Regular", size: 18)!]
//    }
    
    func setTitle() {}
}
