import UIKit

public enum PinLength {
    case fourDigits, sixDigits
    
    init?(from int: Int) {
        switch int {
        case 4:
            self = .fourDigits
        case 6:
            self = .sixDigits
        default:
            return nil
        }
    }
    
    var int: Int {
        switch self {
        case .fourDigits:
            return 4
        case .sixDigits:
            return 6
        }
    }
}

class PinCodeViewController: BaseViewController<PinCodeView> {
    typealias PinCode = [PinCodeKeyboardKey]
    private(set) var pin = PinCode()
    var handler: ((PinCode) -> Void)?
    private(set) var pinLength: PinLength
    
    override init() {
        let int = UserDefaults.standard.integer(forKey: Configurations.DefaultsKeys.pinLength)
        self.pinLength = PinLength(from: int) ?? .fourDigits
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("setup_pin", comment: "")
        changePin(length: pinLength)
        contentView.pinPasswordKeyboard.compilationHandler = { [weak self] pin in
            guard let this = self else { return }
            
            switch pin {
            case .del:
                guard !this.pin.isEmpty else {
                    return
                }
                
                let index = this.pin.count - 1
                this.pin.removeLast()
                this.contentView.pinCodesView.pinCodeIndicatorViews[index].clear()
            default:
                if this.pin.count < this.pinLength.int {
                    this.pin.append(pin)
                    let index = this.pin.count - 1
                    this.contentView.pinCodesView.pinCodeIndicatorViews[index].fill()
                    
                    if this.pin.count == this.pinLength.int {
                        Timer.scheduledTimer(
                            withTimeInterval: 0.1,
                            repeats: false,
                            block: { _ in
                                this.handler?(this.pin)
                        })
                    }
                }
            }
        }
    }
    
    func changePin(length: PinLength) {
        cleanPin()
        
        switch length {
        case .fourDigits:
            contentView.pinCodesView.changeIndicators(count: 4)
        case .sixDigits:
            contentView.pinCodesView.changeIndicators(count: 6)
        }
        
        pinLength = length
    }
    
    func cleanPin() {
        pin = []
        contentView.pinCodesView.pinCodeIndicatorViews.forEach { $0.clear() }
    }
}
