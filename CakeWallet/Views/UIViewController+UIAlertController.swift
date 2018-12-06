import UIKit

extension UIViewController {
    func showSuccessfulyInfo(title: String? = nil, message: String? = nil, withDuration duration: TimeInterval = 0, actions: [CWAlertAction] = [CWAlertAction.okAction], handler: ((CWAlertViewController) -> Void)? = nil) {
        let alert = CWAlertViewController(title: title, message: message, status: .success)
        alert.addActions(actions)
        
        if duration != 0 {
            Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { _ in
                alert.dismiss(animated: true)
            })
        }
        
        presentWithBlur(alert, animated: true) {
            handler?(alert)
        }
    }
    
    func showInfo(title: String? = nil, message: String? = nil, withDuration duration: TimeInterval = 0, actions: [CWAlertAction] = [CWAlertAction.okAction], handler: ((CWAlertViewController) -> Void)? = nil) {
        let alert = CWAlertViewController(title: title, message: message, status: .info)
        alert.addActions(actions)
        
        if duration != 0 {
            Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { _ in
                alert.dismiss(animated: true)
            })
        }
        
        presentWithBlur(alert, animated: true) {
            handler?(alert)
        }
    }
    
    func showInfo(title: String? = nil, innerView: UIView, withDuration duration: TimeInterval = 0, actions: [CWAlertAction] = [CWAlertAction.okAction], handler: ((CWAlertViewController) -> Void)? = nil) {
        let alert = CWAlertViewController(title: title, innerView: innerView, status: .info)
        alert.addActions(actions)
        
        if duration != 0 {
            Timer.scheduledTimer(withTimeInterval: duration, repeats: false, block: { _ in
                alert.dismiss(animated: true)
            })
        }
        
        presentWithBlur(alert, animated: true) {
            handler?(alert)
        }
    }
    
    func showError(title: String? = nil, message: String? = nil, actions: [CWAlertAction] = [CWAlertAction.okAction], handler: ((CWAlertViewController) -> Void)? = nil) {
        let alert = CWAlertViewController(title: title, message: message, status: .error)
        alert.addActions(actions)
        store.dispatch(ApplicationState.Action.changedError(nil))
        presentWithBlur(alert, animated: true) {
            handler?(alert)
        }
    }
    
    func showError(error: Error, actions: [CWAlertAction] = [CWAlertAction.okAction], handler: ((CWAlertViewController) -> Void)? = nil) {
        let alert = CWAlertViewController(title: nil, message: error.localizedDescription, status: .error)
        alert.addActions(actions)
        store.dispatch(ApplicationState.Action.changedError(nil))
        presentWithBlur(alert, animated: true) {
            handler?(alert)
        }
    }
    
    func showSpinner(withTitle title: String? = nil, message: String? = nil, callback: @escaping (CWAlertViewController) -> Void) {
        let alert = CWAlertViewController(title: title, message: message, status: .spinner)
        presentWithBlur(alert, animated: true) { [weak alert] in
            if let alert = alert {
                callback(alert)
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
