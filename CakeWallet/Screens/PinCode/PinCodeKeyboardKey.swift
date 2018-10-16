import Foundation

enum PinCodeKeyboardKey {
    case one, two, three, four, five, six, seven, eight, nine, zero, del, empty
    
    init(from text: String) {
        switch text.lowercased() {
        case "1":
            self = .one
        case "2":
            self = .two
        case "3":
            self = .three
        case "4":
            self = .four
        case "5":
            self = .five
        case "6":
            self = .six
        case "7":
            self = .seven
        case "8":
            self = .eight
        case "9":
            self = .nine
        case "del":
            self = .del
        case "0":
            self = .zero
        default:
            self = .empty
        }
    }
    
    func string() -> String {
        switch self {
        case .one:
            return "1"
        case .two:
            return "2"
        case .three:
            return "3"
        case .four:
            return "4"
        case .five:
            return "5"
        case .six:
            return "6"
        case .seven:
            return "7"
        case .eight:
            return "8"
        case .nine:
            return "9"
        case .del:
            return "Del"
        case .empty:
            return ""
        case .zero:
            return "0"
        }
    }
}

// MARK: [PinCodeKeyboardKey] + string()

extension Array where Element == PinCodeKeyboardKey {
    func string() -> String {
        return self.reduce("", { (res, key) -> String in
            return res + key.string()
        })
    }
}
