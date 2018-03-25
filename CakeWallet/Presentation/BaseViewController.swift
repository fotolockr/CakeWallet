//
//  BaseViewController.swift
//  Wallet
//
//  Created by Cake Technologies 02.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit
import FontAwesome_swift

protocol PresentableAccessView {
    var canBePresented: Bool { get }
    func callback()
}

class BaseViewController<View: BaseView>: UIViewController {
    var contentView: View { return view as! View }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        configureDescription()
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    deinit {
        print("DEINIT - \(self)")
    }
    
    override func loadView() {
        super.loadView()
        view = View()
        configureBinds()
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        guard let presentableView = viewControllerToPresent as? PresentableAccessView else {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
            return
        }
        
        if presentableView.canBePresented {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        } else {
            presentableView.callback()
            completion?()
        }
    }
    
    func updateTabBarIcon(name: FontAwesome) {
        updateTabBarIcon(name: name, title: title ?? "")
    }
    
    func updateTabBarIcon(name: FontAwesome, title: String) {
        tabBarItem.image = UIImage.fontAwesomeIcon(name: name, textColor: .red, size: CGSize(width: 32, height: 32))
        tabBarItem.title = title
    }
    
    func configureDescription() {}
    func configureBinds() {}
}
