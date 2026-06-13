import Foundation
import PostgresNIO

final class PostgresDriverService: Sendable {
    func testConnection(_ connection: DatabaseConnection, password: String?) async throws {
        try await withClient(for: connection, password: password) { client in
            _ = try await client.query("SELECT 1;")
        }
    }

    func listDatabases(
        for connection: DatabaseConnection,
        password: String?
    ) async throws -> [PostgresDatabaseSummary] {
        try await withClient(for: connection, password: password) { client in
            let rows = try await client.query("""
                SELECT datname
                FROM pg_database
                WHERE datistemplate = false
                ORDER BY datname;
                """
            )

            var databases: [PostgresDatabaseSummary] = []
            for try await name in rows.decode(String.self) {
                databases.append(PostgresDatabaseSummary(name: name))
            }
            return databases
        }
    }

    func listObjects(
        for connection: DatabaseConnection,
        database: String,
        password: String?
    ) async throws -> [PostgresObjectSummary] {
        try await withClient(for: connection, database: database, password: password) { client in
            let rows = try await client.query("""
                SELECT table_schema, table_name, table_type
                FROM information_schema.tables
                WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
                ORDER BY table_schema, table_name;
                """
            )

            var objects: [PostgresObjectSummary] = []
            for try await (schema, name, tableType) in rows.decode((String, String, String).self) {
                let kind: PostgresObjectSummary.Kind = tableType == "VIEW" ? .view : .table
                objects.append(PostgresObjectSummary(schema: schema, name: name, kind: kind))
            }
            return objects
        }
    }

    private func withClient<Value>(
        for connection: DatabaseConnection,
        database: String? = nil,
        password: String?,
        operation: @escaping (PostgresClient) async throws -> Value
    ) async throws -> Value {
        let configuration = PostgresClient.Configuration(
            host: connection.host,
            port: connection.port,
            username: connection.username,
            password: password,
            database: database ?? connection.database,
            tls: .disable
        )
        let client = PostgresClient(configuration: configuration)

        return try await withThrowingTaskGroup(of: Void.self, returning: Value.self) { taskGroup in
            taskGroup.addTask {
                await client.run()
            }

            defer {
                taskGroup.cancelAll()
            }

            return try await operation(client)
        }
    }
}
