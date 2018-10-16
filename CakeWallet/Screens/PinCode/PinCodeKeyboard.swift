import UIKit
import FlexLayout

final class PinCodeKeyboard: BaseView {
    private static let rows = 4
    let rootFlexContainer: UIView
    var compilationHandler: ((PinCodeKeyboardKey) -> Void)?
    
    required init() {
        rootFlexContainer = UIView()
        super.init()
    }
    
    override func configureView() {
        super.configureView()
        backgroundColor = .clear
        addSubview(rootFlexContainer)
        
        rootFlexContainer.flex.define { flex in
            let rows = PinCodeKeyboard.rows + 1
            for row in stride(from: 1, to: rows, by: 1) {
                let keysTitles: [PinCodeKeyboardKey] = {
                    switch row {
                    case 1:
                        return [.one, .two, .three]
                    case 2:
                        return [.four, .five, .six]
                    case 3:
                        return [.seven, .eight, .nine]
                    case 4:
                        return [.empty, .zero, .del]
                    default:
                        return []
                    }
                }()
                
                let row = UIView()
                row.flex.addItem().direction(.row).justifyContent(.spaceBetween).define({ flex in
                    keysTitles.forEach {
                        let key = PinCodeKeyButton(pinCode: $0)
                        key.addTarget(self, action: #selector(onKeyHandler(_:)), for: .touchUpInside)
                        let maxSize: CGFloat = 79
                        flex.addItem(key).maxWidth(25%).height(maxSize).aspectRatio(1)
                        
                        if $0 == .empty || $0 == .del {
                            key.backgroundColor = Theme.current.pinKeyReversed.background
                            key.setTitleColor(Theme.current.pinKeyReversed.text, for: .normal)
                        }
                    }
                })
                
                flex.addItem(row).marginTop(22)
            }
            
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rootFlexContainer.flex.layout()
    }
    
    @objc
    private func onKeyHandler(_ key: PinCodeKeyButton) {
        guard key.pinCode != .empty else {
            return
        }
        
        compilationHandler?(key.pinCode)
    }
}
