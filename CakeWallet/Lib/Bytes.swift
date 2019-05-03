import Foundation

func toBinaryStringArray( _ array:[UInt8] ) -> [String] {
    
    var result:[String] = []
    
    for elem in array {
        
        let binStr = byteToBinaryString( elem )
        result.append( binStr )
    }
    
    return result
}

func byteToBinaryString( _ byte:UInt8 ) -> String {
    
    var result = String( byte, radix: 2)
    
    while result.count < 8 {
        
        result = "0" + result
    }
    
    return result
}

func toByteArray( _ hex:String ) -> [UInt8] {
    
    // remove "-" from Hexadecimal
    let hexString = hex.removeWord( "-" )
    
    let size = hexString.count / 2
    var result:[UInt8] = [UInt8]( repeating: 0, count: size ) // array with length = size
    
    // for ( int i = 0; i < hexString.length; i += 2 )
    for i in stride( from: 0, to: hexString.count, by: 2 ) {
        
        let subHexStr = hexString.subString( i, length: 2 )
        
        result[ i / 2 ] = UInt8( subHexStr, radix: 16 )! // ! - because could be null
    }
    
    return result
}

extension String {
    
    func subString( _ from: Int, length: Int ) -> String {
        
        let size = self.count
        
        let to = length + from
        if from < 0 || to > size {
            
            return ""
        }
        
        var result = ""
        
        for ( idx, char ) in self.enumerated() {
            
            if idx >= from && idx < to {
                
                result.append( char )
            }
        }
        
        return result
    }
    
    func removeWord( _ word:String ) -> String {
        
        var result = ""
        
        let textCharArr = Array(self)
        let wordCharArr = Array(word)
        
        var possibleMatch = ""
        
        var i = 0, j = 0
        while i < textCharArr.count {
            
            if textCharArr[ i ] == wordCharArr[ j ] {
                
                if j == wordCharArr.count - 1 {
                    
                    possibleMatch = ""
                    j = 0
                }
                else {
                    
                    possibleMatch.append( textCharArr[ i ] )
                    j += 1
                }
            }
            else {
                
                result.append( possibleMatch )
                possibleMatch = ""
                
                if j == 0 {
                    
                    result.append( textCharArr[ i ] )
                }
                else {
                    
                    j = 0
                    i -= 1
                }
            }
            
            i += 1
        }
        
        return result
    }
}

extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

