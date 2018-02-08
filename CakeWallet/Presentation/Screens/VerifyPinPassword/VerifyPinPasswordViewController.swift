//
//  VerifyPinPasswordViewController.swift
//  Wallet
//
//  Created by Cake Technologies 11/23/17.
//  Copyright © 2017 Cake Technologies. All rights reserved.
//

import UIKit
import PromiseKit

final class VerifyPinPasswordViewController: BaseViewController<BaseView>, BiometricAuthenticationActions, BiometricLoginPresentable {
    
    // MARK: Property injections
    
    var onVerified: VoidEmptyHandler
    var onClose: VoidEmptyHandler
    var onBiometricAuthenticate: () -> Promise<Void> {
        return account.biometricAuthentication
    }
    private let pinPasswordViewController: PinPasswordViewController!
    private let account: AccountSettingsConfigurable & AuthenticationProtocol

    init(account: AccountSettingsConfigurable & AuthenticationProtocol, pinPasswordViewController: PinPasswordViewController) {
        self.account = account
        self.pinPasswordViewController = pinPasswordViewController
        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if account.biometricAuthenticationIsAllow() {
            self.biometricLogin() { self.onVerified?() }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func configureBinds() {
        configureView()
        pinPasswordViewController.onCloseHandler = { [weak self] in
            self?.onClose?()
            self?.dismiss(animated: true)
        }

        pinPasswordViewController.pin { [weak self] pinPassword in
            let alert = UIAlertController.showSpinner(message: "Verifying password")
            self?.present(alert, animated: true)
            
            self?.account.authenticate(password: pinPassword)
                .then {
                    alert.dismiss(animated: true) {
                        self?.onVerified?()
                    }
                }.catch { [weak self] error in
                    alert.dismiss(animated: true){
                        self?.showError(error)
                        self?.pinPasswordViewController.empty()
                    }
            }
        }
    }

    private func configureView() {
        view.addSubview(pinPasswordViewController.view)

        pinPasswordViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension VerifyPinPasswordViewController: PresentableAccessView {
    var canBePresented: Bool {
        return !self.account.isPasswordRemembered
    }

    func callback() {
        onVerified?()
    }
}

