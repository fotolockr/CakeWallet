import Foundation

func amountForDisplayFormatted(from string: String, withLimit limit: Int = 4) -> String {
    let splitted = string.split(separator: ".")
    
    guard splitted.count > 1 else {
        return string
    }
    
    let afterDot = splitted[1]
    
    if afterDot.count > limit {
        let forCut = String(afterDot)
        let cut = String(forCut[0..<limit])
        let beforeDot = String(splitted[0])
        return String(format: "%@.%@...", beforeDot, cut)
    }
    
    return string
}
