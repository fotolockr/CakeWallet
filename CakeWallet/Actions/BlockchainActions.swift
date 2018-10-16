import CakeWalletLib
import CakeWalletCore

public enum BlockchainActions: HandlableAction {
    case fetchBlockchainHeight
    case checkConnection
}
