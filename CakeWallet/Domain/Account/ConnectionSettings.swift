//
//  ConnectionSettings.swift
//  CakeWallet
//
//  Created by FotoLockr on 31.01.2018.
//  Copyright © 2018 FotoLockr. All rights reserved.
//

import Foundation

struct ConnectionSettings {
    let uri: String
    let login: String
    let password: String
    
    static func loadSavedSettings() -> ConnectionSettings? {
        guard let uri = UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.nodeUri) else {
            return nil
        }
        
        let login = UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.nodeLogin) ?? ""
        let password = UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.nodePassword) ?? ""
        
        return ConnectionSettings(uri: uri, login: login, password: password)
    }
    
    init(uri: String, login: String, password: String) {
        self.uri = uri
        self.login = login
        self.password = password
    }
    
    func save() {
        UserDefaults.standard.set(uri, forKey: Configurations.DefaultsKeys.nodeUri)
        UserDefaults.standard.set(login, forKey: Configurations.DefaultsKeys.nodeLogin)
        UserDefaults.standard.set(password, forKey: Configurations.DefaultsKeys.nodePassword)
    }
}
