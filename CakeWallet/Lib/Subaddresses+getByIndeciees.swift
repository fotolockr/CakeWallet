import CWMonero

extension Subaddresses {
    func get(by indecies: [UInt32]) -> [Subaddress] {
        return self.all().filter { indecies.contains($0.index) }
    }
}
