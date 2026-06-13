import Foundation

struct DatabaseConnection: Identifiable, Hashable {
    enum Engine: String, CaseIterable {
        case postgresql = "PostgreSQL"
        case mysql = "MySQL"
        case sqlite = "SQLite"
    }

    let id = UUID()
    var name: String
    var engine: Engine
    var hostDescription: String
    var isConnected: Bool
}

extension DatabaseConnection {
    static let sampleData: [DatabaseConnection] = [
        DatabaseConnection(
            name: "Local Development",
            engine: .postgresql,
            hostDescription: "localhost:5432/app_dev",
            isConnected: true
        ),
        DatabaseConnection(
            name: "Analytics Warehouse",
            engine: .postgresql,
            hostDescription: "warehouse.internal:5432/metrics",
            isConnected: false
        ),
        DatabaseConnection(
            name: "Scratch SQLite",
            engine: .sqlite,
            hostDescription: "~/Databases/scratch.sqlite",
            isConnected: true
        )
    ]
}
