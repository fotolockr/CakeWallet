import UIKit

class AnyBaseViewController: UIViewController {
    var onDismissHandler: (() -> Void)?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        //fixme: remove this shit
        print("Deinit \(self)")
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { // force all actions with UI from main
            if let nav = self.navigationController?.presentingViewController as? UINavigationController {
                nav.viewControllers.first?.view.subviews.forEach { view in
                    if view.tag == blurViewTag {
                        view.removeFromSuperview()
                    }
                }
            } else if let tabbar = self.navigationController?.presentingViewController as? UITabBarController {
                tabbar.view.subviews.forEach { view in
                    if view.tag == blurViewTag {
                        view.removeFromSuperview()
                    }
                }
            } else if let nav = self.presentingViewController as? UINavigationController {
                nav.viewControllers.first?.view.subviews.forEach { view in
                    if view.tag == blurViewTag {
                        view.removeFromSuperview()
                    }
                }
            } else {
                self.presentingViewController?.view.subviews.forEach { view in
                    if view.tag == blurViewTag {
                        view.removeFromSuperview()
                    }
                }
            }
            
            super.dismiss(animated: flag) {
                completion?()
            }
            self.onDismissHandler?()
        }
    }
    
    func configureBinds() {
        if let title = self.title {
            self.title = title
        }
    }
}

