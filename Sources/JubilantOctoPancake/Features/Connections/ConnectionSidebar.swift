import SwiftUI

struct ConnectionSidebar: View {
    let connections: [DatabaseConnection]
    @Binding var selectedConnectionID: DatabaseConnection.ID?

    var body: some View {
        List(selection: $selectedConnectionID) {
            Section("Connections") {
                ForEach(connections) { connection in
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Circle()
                                .fill(connection.isConnected ? Color.green : Color.secondary)
                                .frame(width: 8, height: 8)
                            Text(connection.name)
                                .font(.headline)
                        }

                        Text(connection.hostDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .tag(connection.id)
                }
            }
        }
        .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        .toolbar {
            ToolbarItem {
                Button {
                    // Connection creation will open a sheet once persistence is added.
                } label: {
                    Label("Add Connection", systemImage: "plus")
                }
            }
        }
    }
}
