import Foundation

@MainActor
final class ConnectionStore: ObservableObject {
    @Published private(set) var connections: [DatabaseConnection] = []

    private let fileURL: URL
    private let credentialStore: KeychainCredentialStore

    init(
        fileManager: FileManager = .default,
        credentialStore: KeychainCredentialStore = KeychainCredentialStore()
    ) {
        self.credentialStore = credentialStore

        let supportDirectory = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0]
        .appendingPathComponent("JubilantOctoPancake", isDirectory: true)

        self.fileURL = supportDirectory.appendingPathComponent("connections.json")
        loadConnections(fileManager: fileManager)
    }

    func addPostgresConnection(_ draft: PostgresConnectionDraft) throws {
        guard let port = draft.normalizedPort else {
            throw ConnectionStoreError.invalidPort
        }

        let connection = DatabaseConnection(
            name: draft.trimmedName,
            engine: .postgresql,
            host: draft.trimmedHost,
            port: port,
            database: draft.trimmedDatabase,
            username: draft.trimmedUsername,
            isConnected: false
        )

        try credentialStore.savePassword(draft.password, for: connection.id)
        connections.append(connection)
        try saveConnections()
    }

    private func loadConnections(fileManager: FileManager) {
        guard let data = try? Data(contentsOf: fileURL) else {
            connections = []
            return
        }

        do {
            let decodedConnections = try JSONDecoder().decode([DatabaseConnection].self, from: data)
            connections = decodedConnections.filter { !Self.isSeedConnection($0) }

            if connections.count != decodedConnections.count {
                try? saveConnections(fileManager: fileManager)
            }
        } catch {
            connections = []
        }
    }

    private static func isSeedConnection(_ connection: DatabaseConnection) -> Bool {
        switch (connection.name, connection.host, connection.port, connection.database) {
        case ("Local Development", "localhost", 5432, "app_dev"),
            ("Analytics Warehouse", "warehouse.internal", 5432, "metrics"),
            ("Scratch SQLite", "", 0, "~/Databases/scratch.sqlite"):
            return true
        default:
            return false
        }
    }

    private func saveConnections(fileManager: FileManager = .default) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        try fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )

        let data = try JSONEncoder().encode(connections)
        try data.write(to: fileURL, options: [.atomic])
    }
}

enum ConnectionStoreError: LocalizedError {
    case invalidPort

    var errorDescription: String? {
        switch self {
        case .invalidPort:
            return "Port must be a number."
        }
    }
}
