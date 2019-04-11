import SwiftyJSON

public protocol JSONRepresentable {
    func makeJSON() throws -> JSON
}

public protocol JSONInitializable {
    init(json: JSON)
}

public protocol JSONConvertible: JSONRepresentable, JSONInitializable {}
