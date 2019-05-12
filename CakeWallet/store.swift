import CakeWalletLib
import CakeWalletCore
import CWMonero

func getSavedFiatCurrency() -> FiatCurrency {
    guard
        let raw = UserDefaults.standard.value(forKey: Configurations.DefaultsKeys.currency.string()) as? Int,
        let fiatCurrency = FiatCurrency(rawValue: raw) else {
            return .usd
    }
    
    return fiatCurrency
}

func getSavedTransactionPriority() -> TransactionPriority {
    if UserDefaults.standard.value(forKey: Configurations.DefaultsKeys.transactionPriority.string()) == nil {
        return .slow
    }
    
    let transactionsPriority = TransactionPriority(
        rawValue: UInt64(
            UserDefaults.standard.integer(
                forKey: Configurations.DefaultsKeys.transactionPriority
            )
        )
    )
    
    return transactionsPriority ?? .slow
}

extension TimeZone {
    var isEurope: Bool {
        return self.identifier.split(separator: "/").first?.lowercased() == "europe"
    }
}

func getSavedNode(userDefaults: UserDefaults = UserDefaults.standard) -> NodeDescription? {
    guard
    let uri = userDefaults.string(forKey: Configurations.DefaultsKeys.nodeUri),
    let login = userDefaults.string(forKey: Configurations.DefaultsKeys.nodeLogin),
        let password = userDefaults.string(forKey: Configurations.DefaultsKeys.nodePassword) else {
            userDefaults.set(true, forKey: Configurations.DefaultsKeys.checkForIsEu)
            
            if TimeZone.current.isEurope {
                return Configurations.defaultEuMoneroNode
            }
            
            return Configurations.defaultMoneroNode
    }
    
    if !userDefaults.bool(forKey: Configurations.DefaultsKeys.checkForIsEu) {
        UserDefaults.standard.set(true, forKey: Configurations.DefaultsKeys.checkForIsEu)
        
        if uri == Configurations.defaultMoneroNode.uri {
            if TimeZone.current.isEurope {
                let node = Configurations.defaultEuMoneroNode
                userDefaults.set(node.uri, forKey: Configurations.DefaultsKeys.nodeUri)
                userDefaults.set(node.login, forKey: Configurations.DefaultsKeys.nodeLogin)
                userDefaults.set(node.password, forKey: Configurations.DefaultsKeys.nodePassword)
                return node
            }
        }
    }
    
    return MoneroNodeDescription(uri: uri, login:  login, password:  password)
}

func getSavedIsAutoSwitchNodeOn() -> Bool {
    return UserDefaults.standard.value(forKey: Configurations.DefaultsKeys.autoSwitchNode.string()) != nil
        ? UserDefaults.standard.bool(forKey: Configurations.DefaultsKeys.autoSwitchNode)
        : true
}

func getSavedIsBiometricAuthenticationAllowed() -> Bool {
    return UserDefaults.standard.bool(forKey: Configurations.DefaultsKeys.biometricAuthenticationOn)
}

let store = Store<ApplicationState>(
    initialState: ApplicationState(
        walletState: WalletState(
            name: UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.currentWalletName) ?? "",
            address: "",
            seed: "",
            isWatchOnly: true,
            walletType: .monero,
            walletKeys: nil,
            stage: .none,
            subaddress: nil,
            account: Account(label: "Primary", index: 0)
        ), walletsState: WalletsState(
            wallets: []
        ), settingsState: SettingsState(
            isPinCodeInstalled: false,
            isAuthenticated: false,
            isBiometricAuthenticationAllowed: getSavedIsBiometricAuthenticationAllowed(),
            transactionPriority: getSavedTransactionPriority(),
            node: getSavedNode(),
            isAutoSwitchNodeOn: getSavedIsAutoSwitchNodeOn(),
            fiatCurrency: getSavedFiatCurrency()
        ), balanceState: BalanceState(
            balance: MoneroAmount(value: 0),
            unlockedBalance: MoneroAmount(value: 0),
            price: 0,
            fiatBalance: FiatAmount(from: "0.0", currency: getSavedFiatCurrency()),
            fullFiatBalance: FiatAmount(from: "0.0", currency: getSavedFiatCurrency()),
            rate: 1.0
        ), blockchainState: BlockchainState(
            connectionStatus: .notConnected,
            blockchainHeight: 0,
            currentHeight: 0
        ), transactionsState: TransactionsState(
            transactions: [],
            sendingStage: .none,
            estimatedFee: MoneroAmount(value: 0)
        ), subaddressesState: SubaddressesState(
            subaddresses: []
        ), exchangeState: ExchangeState(
            trade: nil
        ), accountsState: AccountsState(
            accounts: []
        )
    ), effects: [
        HandlerEffect<ApplicationState>(),
        LoggerEffect<ApplicationState>(),
        OnWalletChangeEffect(),
        StartConnectionEffect(),
        startingSyncEffect(),
        OnSyncedEffect(),
        UpdateTransactionsListEffect(),
        UpdateEstimatedFeeEffect(),
        CheckConnectionEffect(),
        KeepIdleTimerEffect(),
        OnCurrentNodeChangeEffect(),
        ChangeFiatPriceEffect(),
        UpdateFiatPriceAfterFiatChangeEffect(),
        UpdateFiatBalanceAfterPriceChangeEffect(),
        OnNewSubaddressAddedEffect(),
        OnSubaddressCahngedEffect(),
        OnAccountChangedEffect(),
        OnNewSubaddressAddedEffect()
    ]
)


