import Foundation

func sort(dateComponents: [DateComponents]) -> [DateComponents] {
    return dateComponents.sorted(by: {
        if $0.year == $1.year {
            if $0.month == $1.month {
                return $0.day! > $1.day!
            }
            
            return $0.month! > $1.month!
        }
        
        return $0.year! > $1.year!
    })
}
