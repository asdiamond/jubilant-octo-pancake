import Foundation

struct DatabaseObject: Identifiable, Hashable {
    enum Kind: String {
        case schema = "Schema"
        case table = "Table"
        case view = "View"
        case function = "Function"
    }

    let id = UUID()
    var name: String
    var kind: Kind
    var rowEstimate: Int?
}

extension DatabaseObject {
    static let sampleData: [DatabaseObject] = [
        DatabaseObject(name: "public", kind: .schema, rowEstimate: nil),
        DatabaseObject(name: "users", kind: .table, rowEstimate: 1248),
        DatabaseObject(name: "orders", kind: .table, rowEstimate: 18542),
        DatabaseObject(name: "active_subscriptions", kind: .view, rowEstimate: 811),
        DatabaseObject(name: "refresh_customer_rollups", kind: .function, rowEstimate: nil)
    ]
}
