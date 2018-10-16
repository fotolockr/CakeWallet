import Foundation

extension String {
    func slice(from: String, to: String?) -> String? {
        guard let startIndex = range(of: from)?.upperBound else {
            return nil
        }
        
        let fromStartToEnd = String(self[startIndex..<endIndex])
        
        if
            let to = to,
            let endIndex = fromStartToEnd.range(of: to)?.lowerBound {
            return String(fromStartToEnd[fromStartToEnd.startIndex..<endIndex])
        }
        
        return fromStartToEnd
    }
}
