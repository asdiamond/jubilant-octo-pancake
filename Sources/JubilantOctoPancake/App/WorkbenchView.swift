import SwiftUI

struct WorkbenchView: View {
    @StateObject private var connectionStore = ConnectionStore()
    private let postgresDriver = PostgresDriverService()
    @State private var selectedConnectionID: DatabaseConnection.ID?
    @State private var selectedObjectID: DatabaseObject.ID?
    @State private var selectedQueryID: QueryDocument.ID?
    @State private var databaseObjects = DatabaseObject.sampleData
    @State private var queries = QueryDocument.sampleData

    var body: some View {
        NavigationSplitView {
            ConnectionSidebar(
                connections: connectionStore.connections,
                selectedConnectionID: $selectedConnectionID
            ) { draft in
                try connectionStore.addPostgresConnection(draft)
            } onLoadDatabases: { connection in
                let password = try connectionStore.password(for: connection)
                return try await postgresDriver.listDatabases(
                    for: connection,
                    password: password
                )
            } onLoadObjects: { connection, database in
                let password = try connectionStore.password(for: connection)
                return try await postgresDriver.listObjects(
                    for: connection,
                    database: database.name,
                    password: password
                )
            }
        } content: {
            DatabaseBrowserView(
                objects: databaseObjects,
                selectedObjectID: $selectedObjectID
            )
        } detail: {
            QueryWorkspaceView(
                queries: $queries,
                selectedQueryID: $selectedQueryID
            )
        }
        .navigationTitle("Jubilant Octo Pancake")
        .onAppear {
            selectedConnectionID = connectionStore.connections.first?.id
            selectedObjectID = databaseObjects.first?.id
            selectedQueryID = queries.first?.id
        }
        .onChange(of: connectionStore.connections) { _, connections in
            if selectedConnectionID == nil {
                selectedConnectionID = connections.first?.id
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .newQueryRequested)) { _ in
            let query = QueryDocument(title: "Untitled Query", sql: "")
            queries.append(query)
            selectedQueryID = query.id
        }
    }
}
