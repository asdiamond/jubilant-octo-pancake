import SwiftUI

struct QueryWorkspaceView: View {
    @Binding var queries: [QueryDocument]
    @Binding var selectedQueryID: QueryDocument.ID?

    var body: some View {
        VStack(spacing: 0) {
            Picker("Query", selection: $selectedQueryID) {
                ForEach(queries) { query in
                    Text(query.title).tag(Optional(query.id))
                }
            }
            .pickerStyle(.segmented)
            .padding([.horizontal, .top], 12)

            Divider()
                .padding(.top, 12)

            QueryEditorView(query: selectedQueryBinding)

            Divider()

            ResultsPreviewView()
                .frame(minHeight: 180, idealHeight: 240)
        }
        .navigationTitle("Query")
        .toolbar {
            ToolbarItemGroup {
                Button {
                    runSelectedQuery()
                } label: {
                    Label("Run Query", systemImage: "play.fill")
                }
                .keyboardShortcut(.return, modifiers: [.command])

                Button {
                    explainSelectedQuery()
                } label: {
                    Label("Explain", systemImage: "chart.bar.doc.horizontal")
                }
            }
        }
    }

    private var selectedQueryBinding: Binding<QueryDocument> {
        Binding {
            guard
                let selectedQueryID,
                let query = queries.first(where: { $0.id == selectedQueryID })
            else {
                return QueryDocument(title: "Untitled Query", sql: "")
            }

            return query
        } set: { updatedQuery in
            guard let index = queries.firstIndex(where: { $0.id == updatedQuery.id }) else {
                return
            }

            queries[index] = updatedQuery
        }
    }

    private func runSelectedQuery() {
        // Query execution belongs behind a database driver service.
    }

    private func explainSelectedQuery() {
        // Query planning can share the same execution pipeline with a different command.
    }
}
