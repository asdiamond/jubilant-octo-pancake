import SwiftUI

struct ConnectionSidebar: View {
    let connections: [DatabaseConnection]
    @Binding var selectedConnectionID: DatabaseConnection.ID?
    var onAddConnection: (PostgresConnectionDraft) throws -> Void
    var onLoadDatabases: (DatabaseConnection) async throws -> [PostgresDatabaseSummary]
    var onLoadObjects: (DatabaseConnection, PostgresDatabaseSummary) async throws -> [PostgresObjectSummary]

    @State private var isPresentingAddConnection = false
    @State private var expandedConnectionIDs: Set<DatabaseConnection.ID> = []
    @State private var expandedDatabaseIDs: Set<String> = []
    @State private var databaseStates: [DatabaseConnection.ID: LoadState<[PostgresDatabaseSummary]>] = [:]
    @State private var objectStates: [String: LoadState<[PostgresObjectSummary]>] = [:]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Connections")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)

                    ForEach(connections) { connection in
                        connectionRow(connection)
                            .padding(.horizontal, 8)
                            .background(selectionBackground(for: connection))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedConnectionID = connection.id
                            }

                        if expandedConnectionIDs.contains(connection.id) {
                            connectionChildren(for: connection)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }

            Button {
                isPresentingAddConnection = true
            } label: {
                Label("Add Connection", systemImage: "plus")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
        .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        .sheet(isPresented: $isPresentingAddConnection) {
            AddPostgresConnectionView { draft in
                try onAddConnection(draft)
            }
        }
    }

    @ViewBuilder
    private func connectionChildren(for connection: DatabaseConnection) -> some View {
        switch databaseStates[connection.id, default: .idle] {
        case .idle:
            EmptyView()
        case .loading:
            sidebarStatusRow("Loading databases...", leading: 42)
        case .failed(let message):
            sidebarStatusRow(message, color: .red, leading: 42)
        case .loaded(let databases):
            if databases.isEmpty {
                sidebarStatusRow("No databases", leading: 42)
            } else {
                ForEach(databases) { database in
                    databaseRow(database, connection: connection)
                        .padding(.leading, 24)

                    if expandedDatabaseIDs.contains(databaseKey(connectionID: connection.id, databaseName: database.name)) {
                        databaseChildren(for: connection, database: database)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func databaseChildren(
        for connection: DatabaseConnection,
        database: PostgresDatabaseSummary
    ) -> some View {
        let key = databaseKey(connectionID: connection.id, databaseName: database.name)

        switch objectStates[key, default: .idle] {
        case .idle:
            EmptyView()
        case .loading:
            sidebarStatusRow("Loading objects...", leading: 58)
        case .failed(let message):
            sidebarStatusRow(message, color: .red, leading: 58)
        case .loaded(let objects):
            if objects.isEmpty {
                sidebarStatusRow("No tables or views", leading: 58)
            } else {
                ForEach(objects) { object in
                    objectRow(object)
                        .padding(.leading, 42)
                }
            }
        }
    }

    private func connectionRow(_ connection: DatabaseConnection) -> some View {
        return HStack(spacing: 7) {
            disclosureButton(
                isExpanded: expandedConnectionIDs.contains(connection.id)
            ) {
                toggleConnection(connection)
            }

            Circle()
                .fill(connection.isConnected ? Color.green : Color.secondary)
                .frame(width: 7, height: 7)

            Text(connection.name)
                .font(.body)
                .fontWeight(.medium)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 26, alignment: .leading)
    }

    private func databaseRow(
        _ database: PostgresDatabaseSummary,
        connection: DatabaseConnection
    ) -> some View {
        let key = databaseKey(connectionID: connection.id, databaseName: database.name)

        return HStack(spacing: 7) {
            disclosureButton(
                isExpanded: expandedDatabaseIDs.contains(key)
            ) {
                toggleDatabase(database, for: connection)
            }

            Image(systemName: "cylinder")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 14)

            Text(database.name)
                .font(.callout)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 26, alignment: .leading)
    }

    private func objectRow(_ object: PostgresObjectSummary) -> some View {
        HStack(spacing: 7) {
            Spacer()
                .frame(width: 19)

            Image(systemName: object.kind == .view ? "eye" : "tablecells")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .frame(width: 14)

            Text("\(object.schema).\(object.name)")
                .font(.callout)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 24, alignment: .leading)
    }

    private func sidebarStatusRow(
        _ message: String,
        color: Color = .secondary,
        leading: CGFloat
    ) -> some View {
        HStack {
            Text(message)
                .font(.caption)
                .foregroundStyle(color)
                .lineLimit(1)

            Spacer(minLength: 0)
        }
        .padding(.leading, leading)
        .frame(maxWidth: .infinity, minHeight: 24, alignment: .leading)
    }

    private func selectionBackground(for connection: DatabaseConnection) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(selectedConnectionID == connection.id ? Color.accentColor : Color.clear)
    }

    private func disclosureButton(
        isExpanded: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 12, height: 18)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
    }

    private func toggleConnection(_ connection: DatabaseConnection) {
        if expandedConnectionIDs.contains(connection.id) {
            expandedConnectionIDs.remove(connection.id)
        } else {
            expandedConnectionIDs.insert(connection.id)
            loadDatabasesIfNeeded(for: connection)
        }
    }

    private func toggleDatabase(
        _ database: PostgresDatabaseSummary,
        for connection: DatabaseConnection
    ) {
        let key = databaseKey(connectionID: connection.id, databaseName: database.name)

        if expandedDatabaseIDs.contains(key) {
            expandedDatabaseIDs.remove(key)
        } else {
            expandedDatabaseIDs.insert(key)
            loadObjectsIfNeeded(for: connection, database: database)
        }
    }

    private func loadDatabasesIfNeeded(for connection: DatabaseConnection) {
        guard databaseStates[connection.id]?.isLoadedOrLoading != true else {
            return
        }

        databaseStates[connection.id] = .loading
        Task {
            do {
                let databases = try await onLoadDatabases(connection)
                databaseStates[connection.id] = .loaded(databases)
            } catch {
                databaseStates[connection.id] = .failed(error.localizedDescription)
            }
        }
    }

    private func loadObjectsIfNeeded(
        for connection: DatabaseConnection,
        database: PostgresDatabaseSummary
    ) {
        let key = databaseKey(connectionID: connection.id, databaseName: database.name)
        guard objectStates[key]?.isLoadedOrLoading != true else {
            return
        }

        objectStates[key] = .loading
        Task {
            do {
                let objects = try await onLoadObjects(connection, database)
                objectStates[key] = .loaded(objects)
            } catch {
                objectStates[key] = .failed(error.localizedDescription)
            }
        }
    }

    private func databaseKey(
        connectionID: DatabaseConnection.ID,
        databaseName: String
    ) -> String {
        "\(connectionID.uuidString):\(databaseName)"
    }
}

private enum LoadState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(String)

    var isLoadedOrLoading: Bool {
        switch self {
        case .loading, .loaded:
            return true
        case .idle, .failed:
            return false
        }
    }
}
