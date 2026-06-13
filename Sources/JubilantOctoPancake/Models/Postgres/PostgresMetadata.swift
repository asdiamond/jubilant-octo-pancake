import Foundation

struct PostgresDatabaseSummary: Identifiable, Hashable {
    var id: String { name }
    var name: String
}

struct PostgresObjectSummary: Identifiable, Hashable {
    enum Kind: String {
        case table = "Table"
        case view = "View"
    }

    var id: String { "\(schema).\(name).\(kind.rawValue)" }
    var schema: String
    var name: String
    var kind: Kind
}
