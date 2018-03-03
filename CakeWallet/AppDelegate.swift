//
//  AppDelegate.swift
//  Wallet
//
//  Created by Cake Technologies 06.10.17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit
import Dip
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var rememberedViewController: UIViewController?
    
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

        window?.rootViewController = authScreen
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
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
        
        let oldDefaultNodeUri = "node.moneroworld.com:18089"
        
        if UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.nodeUri) == oldDefaultNodeUri {
            UserDefaults.standard.set(Configurations.defaultNodeUri, forKey: Configurations.DefaultsKeys.nodeUri)
        }
    }
    
    private func setAppearance() {
        UITabBar.appearance().tintColor = UIColor(hex: 0xA682FF) // FIX-ME: Unnamed constant
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor(hex: 0x006494) // FIX-ME: Unnamed constant
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.black,
            NSAttributedStringKey.font: UIFont.avenirNextMedium(size: 24)
        ]
    }
}

