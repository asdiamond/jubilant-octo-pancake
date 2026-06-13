import Foundation

struct DatabaseConnection: Identifiable, Codable, Hashable {
    enum Engine: String, CaseIterable, Codable {
        case postgresql = "PostgreSQL"
        case mysql = "MySQL"
        case sqlite = "SQLite"
    }

    var id = UUID()
    var name: String
    var engine: Engine
    var host: String
    var port: Int
    var database: String
    var username: String
    var isConnected: Bool

    var hostDescription: String {
        switch engine {
        case .postgresql, .mysql:
            return "\(host):\(port)/\(database)"
        case .sqlite:
            return database
        }
    }
}
