import UIKit

extension UIViewController {
    func showDurationInfoAlert(title: String? = nil, message: String? = nil, duration: TimeInterval) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { _ in
            alertController.dismiss(animated: true)
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showOKInfoAlert(title: String? = nil, message: String? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showInfoAlert(title: String? = nil, message: String? = nil, actions: [UIAlertAction] = []) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(error: Error, handler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        
        store.dispatch(ApplicationState.Action.changedError(nil))
        
        present(alertController, animated: true, completion: handler)
    }
    
    func showSpinnerAlert(withTitle title: String, callback: @escaping (UIAlertController) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let indicatorSize = CGSize(width: 40, height: 40)
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: .zero, size: indicatorSize))
        activityIndicator.hidesWhenStopped = false
        activityIndicator.activityIndicatorViewStyle = .gray
        
        let contentViewController = UIViewController()
        contentViewController.preferredContentSize = indicatorSize
        contentViewController.view.addSubview(activityIndicator)
        contentViewController.view.bringSubview(toFront: activityIndicator)
        
        alertController.setValue(contentViewController, forKey: "contentViewController")
        activityIndicator.startAnimating()
        
        present(alertController, animated: true) { [weak alertController] in
            if let alertController = alertController {
                callback(alertController)
            }
        }
    }
    
    func dismissAlert(_ handler: (() -> Void)? = nil) {
        if presentedViewController is UIAlertController {
            presentedViewController?.dismiss(animated: true, completion: handler)
        }
        
        if presentedViewController is CWAlertViewController {
            presentedViewController?.dismiss(animated: true, completion: handler)
        }
    }
}
