import CakeWalletLib
import CakeWalletCore
import CWMonero

// fixme: all!!!

private func connectToNode(_ wallet: Wallet) throws {
    if let node = store.state.settingsState.node {
        try wallet.connect(toNode: node)
        store.dispatch(BlockchainState.Action.changedConnectionStatus(.connection))
        checkConnectionTimer.resume()
    }
}

public final class StartConnectionEffect: Effect {
    public init() {}
    public func effect(_ store: Store<ApplicationState>, action: WalletState.Action) -> AnyAction? {
        workQueue.async {
            do {
                switch action {
                case let .created(wallet):
                    try connectToNode(wallet)
                case let .loaded(wallet):
                    try connectToNode(wallet)
                case let .restored(wallet):
                    try connectToNode(wallet)
                default:
                    break
                }
            } catch {
                store.dispatch(BlockchainState.Action.changedConnectionStatus(.failed))
                store.dispatch(ApplicationState.Action.changedError(error))
            }
        }
        
        return action
    }
}

let checkConnectionTimer: UTimer = {
    let timer = UTimer(deadline: .now(), repeating: .seconds(5), queue: backgroundConnectionTimerQueue)
    timer.listener = {
        store.dispatch(
            BlockchainActions.checkConnection
        )
    }
    return timer
}()

let backgroundConnectionTimerQueue = DispatchQueue(
    label: "io.cakewallet.backgroundConnectionTimerQueue",
    qos: .default,
    attributes: .concurrent)


private var cachedConnectResults = CachedValue(origin: [String: Bool](), timeout: 60) { // 1min
    return [String: Bool]()
}

private var isSwitching = false

func switchNode(skipNodes: [NodeDescription] = []) {
    guard !isSwitching else { return }
    defer { isSwitching = false }
    isSwitching = true
    
    let nodesList = NodesList.shared
    let nodes = nodesList.compactMap { node -> NodeDescription? in
        if let _ = nodesList.filter({ $0.compare(with: node) }).first {
            return node
        } else {
            return nil
        }
    }
    
    let dispatchGroup = DispatchGroup()
    
    nodes.forEach() { node in
        var isAble = false
        
        if let cachedResult = cachedConnectResults.value()[node.uri] {
            isAble = cachedResult
        } else {
            if let _isAble = cachedConnectResults.value()[node.uri] {
                isAble = _isAble
            } else {
                dispatchGroup.enter()
                node.isAble() { _isAble in
                    isAble = _isAble
                    dispatchGroup.leave()
                }
            }
            var res = cachedConnectResults.value()
            res[node.uri] = isAble
            cachedConnectResults = CachedValue(origin: res, timeout: 60)
        }
        
        if isAble {
            store.dispatch(
                SettingsActions.changeCurrentNode(to: node)
            )
            print("Connection to node: \(node)")
            return
        }
    }
}

final class UTimer {
    var listener: (() -> Void)? {
        didSet {
            timer.setEventHandler { [weak self] in
                self?.listener?()
            }
        }
    }
    
    private enum State {
        case suspended
        case resumed
    }
    
    private let timer: DispatchSourceTimer
    private var state: State = .suspended
    
    init(deadline deadlineTime: DispatchTime, repeating repeatingTime: DispatchTimeInterval,
         queue: DispatchQueue? = nil,  eventHandler: (() -> Void)? = nil) {
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: deadlineTime, repeating: repeatingTime)
        self.listener = eventHandler
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        resume()
        listener = nil
    }
    
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    
    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
}
