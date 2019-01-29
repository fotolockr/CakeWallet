class WizzardStore<State: WizzardRestoreState> {
    private(set) var state: State
    
    init(state: State) {
        self.state = state
    }
    
    func change(state: State) {
        self.state = state
    }
}

protocol WizzardRestoreState {
    var name: String { get }
    var height: UInt64? { get }
    var date: String { get }
}

struct WizzardRestoreFromSeedState: WizzardRestoreState {
    let name: String
    let seed: String
    let height: UInt64?
    let date: String
}

struct WizzardRestoreFromKeysState: WizzardRestoreState {
    let name: String
    let address: String
    let viewKey: String
    let spendKey: String
    let height: UInt64?
    let date: String
}
