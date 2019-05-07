import UIKit
import CakeWalletCore
import CWMonero
import RxSwift
import RxCocoa


final class AccountViewController: BaseViewController<AccountView> {
    weak var flow: DashboardFlow?
    let store: Store<ApplicationState>
    var label: BehaviorRelay<String>
    let disposeBag: DisposeBag
    let account: Account?
    
    init(flow: DashboardFlow?, store: Store<ApplicationState>, account: Account? = nil) {
        self.flow = flow
        self.store = store
        self.label = BehaviorRelay<String>(value: account?.label ?? "")
        self.account = account
        disposeBag = DisposeBag()
        
        super.init()
    }
    
    override func configureBinds() {
        title = "Account"
        contentView.labelContainer.text = label.value
        
        if account == nil {
            contentView.editButton.setTitle("Add", for: .normal)
        }
        
        contentView.labelContainer.rx.text.orEmpty
            .bind(to: label)
            .disposed(by: disposeBag)
        
        contentView.editButton.rx.tap
            .subscribe(onNext: { [weak self] _ in self?.updateAccount() })
            .disposed(by: disposeBag)
    }
    
    private func updateAccount() {
        guard let withSubaddress = account else {
            addSubaddressAction()
            return
        }
        
        store.dispatch(AccountsActions.updateAccount(label.value, withSubaddress.index))
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func addSubaddressAction() {
        guard let label = contentView.labelContainer.text else {
            return
        }
        
        store.dispatch(
            AccountsActions.addNew(
                withLabel: label,
                handler: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
            })
        )
    }
}
