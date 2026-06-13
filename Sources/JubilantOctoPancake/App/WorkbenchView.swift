import SwiftUI

struct WorkbenchView: View {
    @State private var selectedConnectionID: DatabaseConnection.ID?
    @State private var selectedObjectID: DatabaseObject.ID?
    @State private var selectedQueryID: QueryDocument.ID?
    @State private var connections = DatabaseConnection.sampleData
    @State private var databaseObjects = DatabaseObject.sampleData
    @State private var queries = QueryDocument.sampleData

    var body: some View {
        NavigationSplitView {
            ConnectionSidebar(
                connections: connections,
                selectedConnectionID: $selectedConnectionID
            )
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
            selectedConnectionID = connections.first?.id
            selectedObjectID = databaseObjects.first?.id
            selectedQueryID = queries.first?.id
        }
        .onReceive(NotificationCenter.default.publisher(for: .newQueryRequested)) { _ in
            let query = QueryDocument(title: "Untitled Query", sql: "")
            queries.append(query)
            selectedQueryID = query.id
        }
    }
}
