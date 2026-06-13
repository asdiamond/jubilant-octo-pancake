import SwiftUI

struct ConnectionSidebar: View {
    let connections: [DatabaseConnection]
    @Binding var selectedConnectionID: DatabaseConnection.ID?
    var onAddConnection: (PostgresConnectionDraft) throws -> Void

    @State private var isPresentingAddConnection = false

    var body: some View {
        VStack(spacing: 0) {
            List(selection: $selectedConnectionID) {
                Section("Connections") {
                    ForEach(connections) { connection in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(connection.isConnected ? Color.green : Color.secondary)
                                .frame(width: 8, height: 8)
                            Text(connection.name)
                                .font(.headline)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 6)
                        .tag(connection.id)
                    }
                }
            }
            .listStyle(.sidebar)

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
}
