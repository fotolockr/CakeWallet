import Foundation
import CakeWalletLib
import CWMonero

var gateways: [WalletGateway.Type] {
    return [MoneroWalletGateway.self]
}
// fixme!
func getGateway(for type: WalletType) -> WalletGateway {
    var _gateway: WalletGateway.Type?
    
    gateways.forEach {
        if $0.type == type {
            _gateway = $0
        }
    }
    
    let gateway = _gateway ?? MoneroWalletGateway.self // FIX-ME: Hardcoded default value
    return gateway.init()
}
