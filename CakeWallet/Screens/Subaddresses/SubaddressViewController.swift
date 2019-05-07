import UIKit
import CakeWalletCore
import CWMonero
import RxSwift
import RxCocoa

final class SubaddressViewController: BaseViewController<SubaddressView> {
    let store: Store<ApplicationState>
    let label: BehaviorRelay<String>
    let subaddress: Subaddress
    let disposeBag: DisposeBag
    
    init(store: Store<ApplicationState>, subaddress: Subaddress) {
        self.store = store
        self.label = BehaviorRelay<String>(value: subaddress.label)
        self.subaddress = subaddress
        disposeBag = DisposeBag()
        super.init()
    }
    
    override func configureBinds() {
        title = "Edit subaddress"
        contentView.labelContainer.text = label.value
        
        contentView.labelContainer.rx.text.orEmpty
            .bind(to: label)
            .disposed(by: disposeBag)
        
        contentView.editButton.rx.tap
            .subscribe(onNext: { [weak self] _ in self?.updateSubaddress() })
            .disposed(by: disposeBag)
    }
    
    private func updateSubaddress() {
        store.dispatch(SubaddressesActions.updateSubaddress(label.value, subaddress.index))
        navigationController?.popViewController(animated: true)
    }
}
