import UIKit
import CakeWalletCore
import CWMonero
import RxSwift
import RxCocoa


final class SubaddressViewController: BaseViewController<SubaddressView> {
    weak var flow: DashboardFlow?
    let store: Store<ApplicationState>
    var label: BehaviorRelay<String>
    let disposeBag: DisposeBag
    let subaddress: Subaddress?
    
    init(flow: DashboardFlow?, store: Store<ApplicationState>, subaddress: Subaddress? = nil) {
        self.flow = flow
        self.store = store
        self.label = BehaviorRelay<String>(value: subaddress?.label ?? "")
        self.subaddress = subaddress
        disposeBag = DisposeBag()
        
        super.init()
    }
    
    override func configureBinds() {
        title = "Subaddress"
        contentView.labelContainer.text = label.value
        
        if subaddress == nil {
            contentView.editButton.setTitle("Add", for: .normal)
        }
        
        contentView.labelContainer.rx.text.orEmpty
            .bind(to: label)
            .disposed(by: disposeBag)
        
        contentView.editButton.rx.tap
            .subscribe(onNext: { [weak self] _ in self?.updateSubaddress() })
            .disposed(by: disposeBag)
    }
    
    private func updateSubaddress() {
        guard let withSubaddress = subaddress else {
            addSubaddressAction()
            return
        }
        
        store.dispatch(SubaddressesActions.updateSubaddress(label.value, withSubaddress.index))
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func addSubaddressAction() {
        guard let label = contentView.labelContainer.text else {
            return
        }
        
        store.dispatch(
            SubaddressesActions.addNew(
                withLabel: label,
                handler: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
            })
        )
    }
}
