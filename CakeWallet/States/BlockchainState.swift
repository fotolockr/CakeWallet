import CakeWalletLib
import CakeWalletCore

public struct BlockchainState: StateType {    
    public enum Action: AnyAction {
        case changedConnectionStatus(ConnectionStatus)
        case changedBlockchainHeight(UInt64)
        case changedCurrentHeight(UInt64)
    }
    
    public let connectionStatus: ConnectionStatus
    public let blockchainHeight: UInt64
    public let currentHeight: UInt64
    
    public init(connectionStatus: ConnectionStatus, blockchainHeight: UInt64, currentHeight: UInt64) {
        self.connectionStatus = connectionStatus
        self.blockchainHeight = blockchainHeight
        self.currentHeight = currentHeight
    }
    
    public func reduce(_ action: BlockchainState.Action) -> BlockchainState {
        switch action {
        case let .changedBlockchainHeight(blockchainHeight):
            return BlockchainState(connectionStatus: connectionStatus, blockchainHeight: blockchainHeight, currentHeight: currentHeight)
        case let .changedCurrentHeight(currentHeight):
            return BlockchainState(connectionStatus: connectionStatus, blockchainHeight: blockchainHeight, currentHeight: currentHeight)
        case let .changedConnectionStatus(connectionStatus):
            if case let .syncing(height) = connectionStatus {
                return BlockchainState(connectionStatus: connectionStatus, blockchainHeight: blockchainHeight, currentHeight: height)
            }
            
            return BlockchainState(connectionStatus: connectionStatus, blockchainHeight: blockchainHeight, currentHeight: currentHeight)
        }
    }
}
