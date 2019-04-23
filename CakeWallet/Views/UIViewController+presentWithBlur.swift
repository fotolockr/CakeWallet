import UIKit

let blurViewTag = 101

extension UIViewController {
    func presentWithBlur(_ viewControllerToPresent: UIViewController, presentationStyle: UIModalPresentationStyle = .overFullScreen, animated flag: Bool, completion: (() -> Void)? = nil) {
        providesPresentationContextTransitionStyle = true
        definesPresentationContext = true
        viewControllerToPresent.view.backgroundColor = .clear
        viewControllerToPresent.modalPresentationCapturesStatusBarAppearance = true
        viewControllerToPresent.modalPresentationStyle = presentationStyle
        present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    func addBluredSubview() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurVisualEffectView.frame = view.bounds
        blurVisualEffectView.tag = blurViewTag 
        view.addSubview(blurVisualEffectView)
        view.bringSubview(toFront: blurVisualEffectView)
    }
}
