import Foundation
import Alamofire
import CakeWalletLib
import SwiftyJSON
import UIKit

//fixme
private let defaultTimeout: TimeInterval = 5
private let alamofireManager: SessionManager = {
    let serverTrustPolicies: [String: ServerTrustPolicy] = [
        "node.cakewallet.io:18081": .disableEvaluation
    ]
    
    let sessionConfiguration = URLSessionConfiguration.default
    sessionConfiguration.timeoutIntervalForRequest = defaultTimeout
    return Alamofire.SessionManager(
        configuration: sessionConfiguration,
        serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
    )
}()

public class MoneroNodeDescription: NSObject, NodeDescription {
    public let uri: String
    public let login: String
    public let password: String
    
    public init(uri: String, login: String = "", password: String = "") {
        self.uri = uri
        self.login = login
        self.password = password
    }
    
    public func isAble(_ handler: @escaping (Bool) -> Void) {
        let urlString = String(format: "http://%@/json_rpc", uri).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let requestBody: [String: Any] = [
            "jsonrpc": "2.0",
            "id": "0",
            "method": "get_info"
        ]
//        let headers = [
//            "Content-Type" : "application/json"
//        ]
        
        var request = try! URLRequest(url: URL(string: urlString)!, method: .post)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSON(requestBody).rawData()
        var canConnect = false
        
//        if !(login.isEmpty && password.isEmpty) {
//            let host = String(uri.split(separator: ":").first!)
//            let port = Int(uri.split(separator: ":")[1])!
//            let credential = URLCredential(user: login, password: password, persistence: .permanent)
//            let protectionSpace = URLProtectionSpace(host: host, port: port, protocol: nil, realm: nil, authenticationMethod: nil)
//            //            URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)
//            if let storage = alamofireManager.session.configuration.urlCredentialStorage {
//                storage.set(credential, for: protectionSpace)
//            }
//            URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)
////            let credentialData = String(format: "%@:%@", login, password).data(using: String.Encoding.utf8)!
////            let base64Credentials = credentialData.base64EncodedString(options: [])
////            request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
//
//            if let authorizationHeader = Request.authorizationHeader(user: login, password: password) {
//                request.setValue(authorizationHeader.value, forHTTPHeaderField: authorizationHeader.key)
//            }
//        }
        
        alamofireManager.request(request)
            .validate()
            .response(completionHandler: { response in
                if let response = response.response {
                    canConnect = (response.statusCode >= 200 && response.statusCode < 300)
                        || response.statusCode == 401
                }
                
                handler(canConnect)
            })
    }
}
