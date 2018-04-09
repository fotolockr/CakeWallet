//
//  ConnectionSettings.swift
//  CakeWallet
//
//  Created by Cake Technologies 31.01.2018.
//  Copyright © 2018 Cake Technologies. 
//

import Foundation
import PromiseKit

enum CheckConnectionError: Error {
    case cannotConnect
}

struct ConnectionSettings: Equatable {
    let uri: String
    let login: String
    let password: String
    
    static func loadSavedSettings() -> ConnectionSettings {
        guard let uri = UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.nodeUri) else {
            return ConnectionSettings(uri: Configurations.defaultNodeUri, login: "", password: "")
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
    
    func connect() -> Promise<(Bool, ConnectionSettings)> {
        let comp = uri.components(separatedBy: ":")
        guard let address = comp.first, let port = Int32(comp[1]) else {
            return Promise(value: (false, self))
        }
        
        return checkConnectionAsync(toAddress: address, port: port)
            .then { return ($0, self) }
    }
}
