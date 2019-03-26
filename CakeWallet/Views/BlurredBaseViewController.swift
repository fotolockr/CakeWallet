import UIKit
import VisualEffectView

class BlurredBaseViewController<View: BaseView>: BaseViewController<View> {
    lazy var visualEffectView: VisualEffectView = {
        let visualEffectView = VisualEffectView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 0)))
        visualEffectView.colorTint = UIColor(red: 211, green: 219, blue: 231)
        visualEffectView.colorTintAlpha = 0.65
        visualEffectView.blurRadius = 4.5
        visualEffectView.scale = 1
        return visualEffectView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        view.backgroundColor = .clear
        modalPresentationStyle = .custom
        view.addSubview(visualEffectView)
        view.sendSubview(toBack: visualEffectView)
        
        if let navController = navigationController {
            navController.view.isOpaque = false
            navController.view.backgroundColor = .clear
            navController.modalPresentationStyle = .custom
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        visualEffectView.frame = CGRect(origin: visualEffectView.frame.origin, size: view.frame.size)
    }
}
