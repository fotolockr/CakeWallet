//
//  AppDelegate.swift
//  Wallet
//
//  Created by Cake Technologies 06.10.17.
//  Copyright © 2017 Cake Technologies. 
//

import UIKit
import Dip
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var rememberedViewController: UIViewController?
    private var blurEffectView: UIVisualEffectView?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.sharedManager().enable = true
        setAppearance()
        initConfigurations()
        window = UIWindow(frame: UIScreen.main.bounds)
        let flow = try! container.resolve(arguments: window!) as RootFlow
        flow.changeRoute(.start)
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        guard
            let viewController = window?.rootViewController,
            !biometricIsShown && self.blurEffectView == nil else {
                return
        }
        
        let vc: UIViewController
        
        if let presentedVC = viewController.presentedViewController {
            vc = presentedVC
        } else {
            vc = viewController
        }
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        self.blurEffectView = blurEffectView
        blurEffectView.frame = vc.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.view.addSubview(blurEffectView)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        let account: Account & AuthenticationProtocol = try! container.resolve() as AccountImpl
        
        guard account.isAuthenticated() && !(window?.rootViewController is AuthenticateViewController) else {
            return
        }
        
        if window?.rootViewController?.presentedViewController?.modalPresentationStyle == .custom {
            window?.rootViewController?.dismiss(animated: false)
            rememberedViewController = window?.rootViewController
        } else if rememberedViewController == nil {
            rememberedViewController = window?.rootViewController
        }
        
        let authScreen = try! container.resolve(arguments: account) as AuthenticateViewController
        authScreen.onLogined = {
            self.window?.rootViewController = self.rememberedViewController
        }
        
        self.blurEffectView?.removeFromSuperview()
        window?.rootViewController = authScreen
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let blurEffectView = self.blurEffectView {
            blurEffectView.removeFromSuperview()
            self.blurEffectView = nil
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    private func initConfigurations() {
        if UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.nodeUri) == nil {
            UserDefaults.standard.set(Configurations.defaultNodeUri, forKey: Configurations.DefaultsKeys.nodeUri)
        }
        
        if UserDefaults.standard.value(forKey: Configurations.DefaultsKeys.currency.stringify()) == nil {
            UserDefaults.standard.set(Configurations.defaultCurreny.rawValue, forKey: Configurations.DefaultsKeys.currency)
        }
        
        // FIX-ME: Replce to migration and make migrations.
        if UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.nodeUri)?.lowercased() == Configurations.preDefaultNodeUri.lowercased() {
            UserDefaults.standard.set(true, forKey: Configurations.DefaultsKeys.defaultNodeChanged)
            UserDefaults.standard.set(Configurations.defaultNodeUri, forKey: Configurations.DefaultsKeys.nodeUri)
        }
        
        if NodesList.url !=  NodesList.originalNodesListUrl
            && !FileManager.default.fileExists(atPath: NodesList.url.path) {
            try? FileManager.default.copyItem(at: NodesList.originalNodesListUrl, to: NodesList.url)
        }
        
        if UserDefaults.standard.value(forKey: Configurations.DefaultsKeys.autoSwitchNode.stringify()) == nil {
             UserDefaults.standard.set(true, forKey: Configurations.DefaultsKeys.autoSwitchNode.stringify())
        }
        
        let nodeConnectionControl = try! container.resolve() as NodeConnectionControl
        nodeConnectionControl.start()
        
//        nodeConnectionControl.getRandomAvailableNode()
//            .then { node -> Void in
//                if let node = node {
//                    UserDefaults.standard.set(node.uri, forKey: Configurations.DefaultsKeys.nodeUri)
//                }
//        }
    }
    
    private func setAppearance() {
        UITabBar.appearance().tintColor = .pictonBlue
//        UITabBar.appearance().unselectedItemTintColor = UIColor(hex: 0xC0D4E2)
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor(hex: 0x006494) // FIX-ME: Unnamed constant
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.black,
            NSAttributedStringKey.font: UIFont.avenirNextMedium(size: 24)
        ]
    }
}

