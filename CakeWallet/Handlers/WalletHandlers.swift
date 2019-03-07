import CakeWalletLib
import CakeWalletCore
import CWMonero

public struct ConnectToNodeHandler: AsyncHandler {
    public func handle(action: WalletActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case let .connect(node) = action else { return }
        
        walletQueue.async {
            do {
                handler(BlockchainState.Action.changedConnectionStatus(.connection))
                try currentWallet.connect(toNode: node)
            } catch {
                handler(ApplicationState.Action.changedError(error))
                handler(BlockchainState.Action.changedConnectionStatus(ConnectionStatus.failed))
            }
        }
    }
}

public struct ConnectToCurrentNodeHandler: AsyncHandler {
    public func handle(action: WalletActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard
            case .connectToCurrentNode = action,
            let node = store.state.settingsState.node else { return }
        
        walletQueue.async {
            do {
                handler(BlockchainState.Action.changedConnectionStatus(.connection))
                try currentWallet.connect(toNode: node)
                checkConnectionTimer.resume()
            } catch {
                handler(ApplicationState.Action.changedError(error))
                handler(BlockchainState.Action.changedConnectionStatus(ConnectionStatus.failed))
            }
        }
    }
}

public struct ReconnectToNodeHandler: AsyncHandler {
    public func handle(action: WalletActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case .reconnect = action else { return }
        
        if let node = store.state.settingsState.node {
            handler(WalletActions.connect(node))
            return
        }
        
        handler(nil)
    }
}

public struct SaveHandler: AsyncHandler {
    public func handle(action: WalletActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case .save = action else { return }
        
        walletQueue.async {
            do {
                try currentWallet.save()
            } catch {
                handler(ApplicationState.Action.changedError(error))
            }
        }
    }
}

public struct CreateTransactionHandler: AsyncHandler {
    public func handle(action: WalletActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case let .send(amount, address, paymentID, priority, completionHandler) = action else { return }
        
        walletQueue.async {
            do {
                let pendingTransaction: PendingTransaction
                
                if let moneroWallet = currentWallet as? MoneroWallet {
                    pendingTransaction = try moneroWallet.send(
                        amount: amount,
                        to: address,
                        paymentID: paymentID,
                        withPriority: priority)
                } else {
                    pendingTransaction = try currentWallet.send(
                        amount: amount,
                        to: address,
                        withPriority: priority)
                }
                
                handler(
                    TransactionsState.Action.changedSendingStage(
                        SendingStage.pendingTransaction(pendingTransaction)
                    )
                )
                
                completionHandler(.success(pendingTransaction))
            } catch {
                handler(ApplicationState.Action.changedError(error))
                completionHandler(.failed(error))
            }
        }
    }
}

public struct CommitTransactionHandler: AsyncHandler {
    public func handle(action: WalletActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case let .commit(transaction, completionHandler) = action else { return }
        store.dispatch(
            TransactionsState.Action.changedSendingStage(SendingStage.commiting)
        )
        
        walletQueue.async {
            transaction.commit({ result in
                switch result {
                case .success():
                    handler(
                        TransactionsState.Action.changedSendingStage(SendingStage.commited)
                    )
                    completionHandler(.success(()))
                case let .failed(error):
                    handler(ApplicationState.Action.changedError(error))
                    completionHandler(.failed(error))
                }
            })
        }
    }
}

public struct RescanHandler: AsyncHandler {
    public func handle(action: WalletActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case let .rescan(height, completionHandler) = action else { return }
        
        do {
            let name = currentWallet.name
            let moneroWallet = currentWallet as! MoneroWallet
            let password = try KeychainStorageImpl.standart.fetch(
                forKey: KeychainKey.walletPassword(
                    WalletIndex(name: name, type: .monero)
                )
            )

            try moneroWallet.rescan(from: height, password: password)
            
            handler(WalletState.Action.restored(currentWallet))
            completionHandler()
        } catch {
            handler(ApplicationState.Action.changedError(error))
            completionHandler()
        }
    }
}

public struct FetchSeedHandler: Handler {
    public func handle(action: WalletActions, store: Store<ApplicationState>) -> AnyAction? {
        guard case .fetchSeed = action else { return nil }
        return WalletState.Action.changedSeed(currentWallet.seed)
    }
}

public struct LoadWalletHandler: AsyncHandler {
    public func handle(action: WalletActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case let .load(name, type, completionHandler) = action else { return }
        
        walletQueue.async {
            do {
                let index = WalletIndex(name: name, type: type)
                let password = try KeychainStorageImpl.standart.fetch(forKey: KeychainKey.walletPassword(index))
                let wallet = try getGateway(for: type).load(withName: name, andPassword: password)
                handler(WalletState.Action.loaded(wallet))
                completionHandler()
            } catch {
                if error.localizedDescription == "std::bad_alloc" {
                    try! MoneroWalletGateway.init().removeCacheFile(for: name)
                    self.handle(action: action, store: store, handler: handler)
                    return
                }
                
                handler(ApplicationState.Action.changedError(error))
                completionHandler()
            }
        }
    }
}

public struct LoadCurrentWalletHandler: AsyncHandler {
    public func handle(action: WalletActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case .loadCurrentWallet = action else { return }
        
        let name = store.state.walletState.name.isEmpty ? UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.currentWalletName) ?? "" : store.state.walletState.name
            
        do {
            let type = store.state.walletState.walletType
            let index = WalletIndex(name: name, type: type)
            let password = try KeychainStorageImpl.standart.fetch(forKey: KeychainKey.walletPassword(index))
            let wallet = try getGateway(for: type).load(withName: name, andPassword: password)
            handler(WalletState.Action.inited(wallet))
        } catch {
            handler(ApplicationState.Action.changedError(error))
        }
    }
}

public struct CreateWalletHandler: AsyncHandler {
    public func handle(action: WalletActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case let .create(name, type, completionHandler) = action else { return }
        
        walletQueue.async {
            do {
                let password = UUID().uuidString
                let wallet = try getGateway(for: type).create(withName: name, andPassword: password)
                let index = WalletIndex(name: name, type: type)
                try KeychainStorageImpl.standart.set(value: password, forKey: KeychainKey.walletPassword(index))
                try KeychainStorageImpl.standart.set(value: wallet.seed, forKey: .seed(index))
                handler(WalletState.Action.created(wallet))
                completionHandler(.success(wallet.seed))
            } catch {
                handler(ApplicationState.Action.changedError(error))
                completionHandler(.failed(error))
            }
        }
    }
}

// fixme
private func restoreFromMymonero(seed: String, name: String, restoreHeight: UInt64, handler: @escaping (AnyAction?) -> Void, completionHandler: @escaping () -> Void) {
    let mn = mndecode(seed: seed)
    var _d = toByteArray(mn)
    let psk = MoneroWalletAdapter.psk(&_d)!
    let pvk = MoneroWalletAdapter.pvk(&_d)!
    let pubSk = MoneroWalletAdapter.secretKey(toPublic: psk)!
    let pubVk = MoneroWalletAdapter.secretKey(toPublic: pvk)!
    
    let address = MoneroWalletAdapter.getAddressFromViewKey(pubVk, andSpendKey: pubSk)!
    let restoreFromKeysWalletHandler = RestoreFromKeysWalletHandler()
    restoreFromKeysWalletHandler.handle(
        action: WalletActions.restoreFromKeys(
            withName: name,
            andAddress: address,
            viewKey: pvk.hexDescription,
            spendKey: psk.hexDescription,
            restoreHeight: restoreHeight,
            type: .monero,
            handler: completionHandler),
        store: store,
        handler: handler)
}

public struct RestoreFromSeedWalletHandler: AsyncHandler {
    public func handle(action: WalletActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case let .restoreFromSeed(name, seed, restoreHeight, type, completionHandler) = action else { return }
        let words = seed.components(separatedBy: " ").reduce(0) { (i, _) -> Int in
            return i + 1
        }
        
        if words == 13 {
            restoreFromMymonero(seed: seed, name: name, restoreHeight: restoreHeight, handler: handler, completionHandler: completionHandler)
            return
        }
        
        walletQueue.sync {
            do {
                let password = UUID().uuidString
                let wallet = try getGateway(for: type).recoveryWallet(
                    withName: name,
                    andSeed: seed,
                    password: password,
                    restoreHeight: restoreHeight)
                let index = WalletIndex(name: name, type: type)
                try KeychainStorageImpl.standart.set(value: password, forKey: KeychainKey.walletPassword(index))
                try KeychainStorageImpl.standart.set(value: wallet.seed, forKey: .seed(index))
                handler(WalletState.Action.restored(wallet))
                completionHandler()
            } catch {
                handler(ApplicationState.Action.changedError(error))
                completionHandler()
            }
        }
    }
}

public struct RestoreFromKeysWalletHandler: AsyncHandler {
    public func handle(action: WalletActions, store: Store<ApplicationState>, handler: @escaping (AnyAction?) -> Void) {
        guard case let .restoreFromKeys(name, address, viewKey, spendKey, restoreHeight, type, completionHandler) = action else { return }
        
        walletQueue.sync {
            do {
                let password = UUID().uuidString
                let wallet = try getGateway(for: type).recoveryWallet(
                    withName: name,
                    publicKey: address,
                    viewKey: viewKey,
                    spendKey: spendKey,
                    password: password,
                    restoreHeight: restoreHeight)
                let index = WalletIndex(name: name, type: type)
                try KeychainStorageImpl.standart.set(value: password, forKey: KeychainKey.walletPassword(index))
                try KeychainStorageImpl.standart.set(value: wallet.seed, forKey: .seed(index))
                handler(WalletState.Action.restored(wallet))
                completionHandler()
            } catch {
                handler(ApplicationState.Action.changedError(error))
                completionHandler()
            }
        }
    }
}
