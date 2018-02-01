//
//  AuthFlow.swift
//  Wallet
//
//  Created by Mykola Misiura on 11/22/17.
//  Copyright © 2017 Mykola Misiura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Dip

protocol RouteType {}

protocol Flow {
    associatedtype Route: RouteType
    typealias FinishHandler = (() -> Void)?
    var currentViewController: UIViewController { get }
    var finalHandler: FinishHandler { get set }
    
    func changeRoute(_ route: Route)
}

final class SignUpFlow: Flow {
    enum Route: RouteType {
        case start
        case setupPinPassword
        case addPinPassword
        case newWallet
        case recoveryWallet
    }
    
    var currentViewController: UIViewController {
        return rootViewController
    }
    private let rootViewController: UINavigationController
    private let type: WalletType
    var finalHandler: Flow.FinishHandler
    
    init(rootViewController: UINavigationController) {
        type = .monero
        self.rootViewController = rootViewController
    }
    
    func changeRoute(_ route: Route) {        
        switch route {
        case .start:
            setupWelcomeRoute()
        case .addPinPassword:
            break
        case .setupPinPassword:
            setSetupPinPasswordRoute()
        case .newWallet:
            setNewWalletRoute()
        case .recoveryWallet:
            setRecoverWalletRoute()
        }
    }
    
    func setupWelcomeRoute() {
        let welcomeViewController = try! container.resolve() as WelcomeViewController
        welcomeViewController.start = { self.changeRoute(Route.setupPinPassword) }
        rootViewController.pushViewController(welcomeViewController, animated: true)
    }
    
    func setAddWalletRoute() {
        let addWalletViewController = try! container.resolve(arguments: type) as AddWalletViewController
        rootViewController.pushViewController(addWalletViewController, animated: true)
    }
    
    func setSetupPinPasswordRoute() {
        let setupPinPasswordViewController = try! container.resolve() as SetupPinPasswordViewController
        setupPinPasswordViewController.setuped = { self.changeRoute(Route.newWallet) }
        rootViewController.pushViewController(setupPinPasswordViewController, animated: true)
    }
    
    func setNewWalletRoute() {
        let newWalletViewController = try! container.resolve(arguments: WalletType.monero) as NewWalletViewController
        newWalletViewController.walletCreated = { self.setSeedDisplayingRoute(seed: $0) }
        rootViewController.pushViewController(newWalletViewController, animated: true)
    }
    
    func setRecoverWalletRoute() {
        let recoverWalletViewController = try! container.resolve(arguments: type) as RecoveryViewController
        recoverWalletViewController.recovered = { self.finalHandler?() }
        rootViewController.pushViewController(recoverWalletViewController, animated: true)
    }
    
    func setSeedDisplayingRoute(seed: String) {
        let seedViewController = try! container.resolve(arguments: seed) as SeedViewController
        seedViewController.finishHandler = { self.finalHandler?() }
        rootViewController.pushViewController(seedViewController, animated: true)
    }
}


final class MainFlow: Flow {
    enum Route: RouteType {
        case start
        case receive
        case send
        case settings
    }
    
    var currentViewController: UIViewController {
        return rootViewController
    }
    var finalHandler: Flow.FinishHandler
    private let rootViewController: UITabBarController
    
    init(rootViewController: UITabBarController) {
        self.rootViewController = rootViewController
    }
    
    func changeRoute(_ route: Route) {
        switch route {
        case .start:
            setSummaryRoute()
        case .receive:
            setReceiveRoute()
        case .send:
            setSendRoute()
        case .settings:
            setSettingsRoute()
        }
    }
    
    func setSummaryRoute() {
        rootViewController.selectedIndex = 0
    }
    
    func setReceiveRoute() {
        rootViewController.selectedIndex = 1
    }
    
    func setSendRoute() {
        rootViewController.selectedIndex = 2
    }
    
    func setSettingsRoute() {
        rootViewController.selectedIndex = 3
    }
}

final class RootFlow: Flow {
    enum Route: RouteType {
        case start
    }
    
    var currentViewController: UIViewController {
        if let viewController = self.window.rootViewController {
            return viewController
        }
        
        let viewController = UIViewController()
        self.window.rootViewController = viewController
        return viewController
    }
    var finalHandler: Flow.FinishHandler
    private let authFlow: SignUpFlow
    private let mainFlow: MainFlow
    private let window: UIWindow
    
    init(window: UIWindow, authFlow: SignUpFlow, mainFlow: MainFlow) {
        self.window = window
        self.authFlow = authFlow
        self.mainFlow = mainFlow
    }
    
    func changeRoute(_ route: Route) {
        switch route {
        case .start:
            start()
        }
    }
    
    private func start() {
        guard
            let name = UserDefaults.standard.string(forKey: "current_wallet_name"),
            let rawType = UserDefaults.standard.value(forKey: "current_wallet_type") as? Int,
            let type = WalletType(rawValue: rawType) else {
                openAuthFlow()
            return
        }
        
        window.rootViewController = nil
    }
    
    private func openAuthFlow() {
        window.rootViewController = authFlow.currentViewController
        authFlow.changeRoute(.start)
    }
}


typealias VoidEmptyHandler = (() -> Void)?

protocol SetupPinPasswordViewControllerType {
    var setuped: VoidEmptyHandler { get }
    var createPinPasswordUseCase: CreatePinPasswordUseCase { get }
}

final class SetupPinPasswordViewController: BaseViewController<BaseView>, SetupPinPasswordViewControllerType {
    var setuped: VoidEmptyHandler
    let createPinPasswordUseCase: CreatePinPasswordUseCase
    private let pinPasswordViewController: PinPasswordViewController
    private let disposeBag: DisposeBag
    private let password: Variable<String>
    
    init(createPinPasswordUseCase: CreatePinPasswordUseCase) {
        self.createPinPasswordUseCase = createPinPasswordUseCase
        pinPasswordViewController = PinPasswordViewController()
        password = Variable<String>("")
        disposeBag = DisposeBag()
        super.init()
        title = "Setup Pin"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    override func configureBinds() {
        pinPasswordViewController.pin { [weak self] pinPassword in
            guard let this = self else { return }
            
            if this.password.value.isEmpty {
                this.password.value = pinPassword
                this.prepareRepeatingPinPassword()
                return
            }
            
            guard this.password.value == pinPassword else {
                // TODO: SHOW ALERT!
                print("Incorrect pin")
                return
            }
            
            this.createPinPasswordUseCase.create(pinPassword: pinPassword)
                .subscribe(
                    onNext: { this.showSuccessAlert() },
                    onError: { this.showError($0) })
                .addDisposableTo(this.disposeBag)
        }
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: nil, message: "Pin password setuped successfully", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { _ in
            self.reset()
            self.setuped?()
        }
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    private func reset() {
        pinPasswordViewController.descriptionText = "Enter your pin"
        pinPasswordViewController.empty()
        password.value = ""
    }
    
    private func setView() {
        view.addSubview(pinPasswordViewController.view)
        
        pinPasswordViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func prepareRepeatingPinPassword() {
        pinPasswordViewController.descriptionText = "Repeat your pin"
        pinPasswordViewController.empty()
    }
}

final class WelcomeView: BaseView {
    let welcomeLabel: UILabel
    let welcomeSubtitleLabel: UILabel
    let descriptionTextView: UITextView
    let startButton: UIButton
    
    required init() {
        welcomeLabel = UILabel(font: .avenirNextMedium(size: 64))
        welcomeSubtitleLabel = UILabel(font: .avenirNextMedium(size: 32))
        descriptionTextView = UITextView()
        startButton = PrimaryButton(title: "Next")
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        welcomeLabel.text = "Welcome"
        welcomeSubtitleLabel.text = "to Cryptonist"
        descriptionTextView.text = "There are will be awesome description text, that need start by creating password."
        descriptionTextView.font = .avenirNextMedium(size: 17)
        descriptionTextView.isEditable = false
        descriptionTextView.layer.masksToBounds = true
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.isScrollEnabled = false
        addSubview(welcomeSubtitleLabel)
        addSubview(welcomeLabel)
        addSubview(descriptionTextView)
        addSubview(startButton)
    }
    
    override func configureConstraints() {
        welcomeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(50)
        }
        
        welcomeSubtitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalTo(welcomeLabel.snp.bottom)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.top.equalTo(welcomeSubtitleLabel.snp.bottom).offset(50)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        startButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-25)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(50)
        }
    }
}

protocol WelcomeViewControllerType {
    typealias StartHandler = (() -> Void)?
    var start: StartHandler { get }
}

final class WelcomeViewController: BaseViewController<WelcomeView>, WelcomeViewControllerType {
    var start: StartHandler
    private let disposeBag: DisposeBag
    
    override init() {
        disposeBag = DisposeBag()
        super.init()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func configureBinds() {
        contentView.startButton.rx.controlEvent(.touchUpInside)
            .subscribe { [weak self] _ in self?.start?() }
            .addDisposableTo(disposeBag)
    }
}

extension UITabBarController {
    convenience init(viewControllers: [UIViewController]) {
        self.init()
        self.setViewControllers(viewControllers, animated: false)
    }
}

