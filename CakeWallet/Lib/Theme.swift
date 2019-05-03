import UIKit

enum Theme: String {
    case def, night
    
    static var current: Theme {
        if
            let rawValue = UserDefaults.standard.string(forKey: Configurations.DefaultsKeys.currentTheme),
            let theme = Theme(rawValue: rawValue) {
            return theme
        }
        
        return .def
    }
    
    var container: ContainerColorScheme {
        switch self {
        case .def:
            return ContainerColorScheme(background: .white)
        case .night:
            return ContainerColorScheme(background: .wildDarkBlue)
        }
    }
    
    var primaryButton: ButtonColorScheme {
        switch self {
        case .def:
            return ButtonColorScheme(background: .purpleyLight, text: .black)
        case .night:
            return ButtonColorScheme(background: .whiteSmoke, text: .vividBlue)
        }
    }
    
    var secondaryButton: ButtonColorScheme {
        switch self {
        case .def:
            return ButtonColorScheme(background: .grayBackground, text: .white)
        case .night:
            return ButtonColorScheme(background: .whiteSmoke, text: .wildDarkBlue)
        }
    }
    
    var pin: PinIndicatorScheme {
        return PinIndicatorScheme(background: .white, value: .turquoiseBlue)
    }
    
    var pinKey: PinKeyScheme {
        return PinKeyScheme(background: .grayBackground, text: .grayBlue)
    }
    
    var pinKeyReversed: PinKeyReversedScheme {
        return PinKeyReversedScheme(background: .white, text: .spaceViolet)
    }
    
    var card: CardScheme {
        return CardScheme(background: .white)
    }
    
    var text: UIColor {
        switch self {
        case .def:
            return .spaceViolet
        case .night:
            return .whiteSmoke
        }
    }
    
    var lightText: UIColor {
        switch self {
        case .def:
            return .wildDarkBlue
        case .night:
            return .whiteSmoke
        }
    }
    
    var progressBar: ProgressBarScheme {
        return ProgressBarScheme(value: .turquoiseBlue, background: .whiteSmoke)
    }
}
