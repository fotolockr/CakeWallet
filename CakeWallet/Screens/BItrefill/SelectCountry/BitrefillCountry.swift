enum BitrefillCountry: String {
    case af, ax, al, dz, ad, ao, ai, aq, ar, am, aw, au, at, az, bs, bh, bd, bb, by, be, br, bg, ca, cn, dk,
    eu, fr, de, mx, ua, ru, us
    
    static var all: [BitrefillCountry] {
        return [
            .af, .ax, .al, .dz, .ad, .ao, .ai, .aq, .ar, .am, .aw, .au, .at, .az, .bs, .bh, .bd, .bb, .by, .be, .br, .bg, .ca, .cn, .dk,
            .eu, .fr, .de, .ua, ru, .us
        ]
    }
    
    func fullCountryName() -> String {
        switch self {
        case .af: return "Afghanistan"
        case .ax: return "Aland Islands"
        case .al: return "Albania"
        case .dz: return "Algeria"
        case .ad: return "Andorra"
        case .ao: return "Angola"
        case .ai: return "Anguilla"
        case .aq: return "Antarctica"
        case .ar: return "Argentina"
        case .am: return "Armenia"
        case .aw: return "Aruba"
        case .au: return "Australia"
        case .at: return "Austria"
        case .az: return "Azerbaijan"
        case .bs: return "Bahams"
        case .bh: return "Bahrain"
        case .bd: return "Bangladesh"
        case .bb: return "Barbados"
        case .by: return "Belarus"
        case .be: return "Belgium"
        case .br: return "Brazil"
        case .bg: return "Bulgaria"
        case .ca: return "Canada"
        case .cn: return "China"
        case .dk: return "Denmark"
        case .eu: return "EU"
        case .fr: return "France"
        case .de: return "Germany"
        case .mx: return "Mexico"
        case .ua: return "Ukraine"
        case .ru: return "Russia"
        case .us: return "USA"
        }
    }
}
