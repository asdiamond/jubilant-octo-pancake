import SwiftUI

struct QueryEditorView: View {
    @Binding var query: QueryDocument
    @AppStorage("queryFontSize") private var queryFontSize = 13.0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(query.title)
                    .font(.headline)

                Spacer()

                Text("PostgreSQL")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            TextEditor(text: $query.sql)
                .font(.system(size: queryFontSize, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(8)
        }
        .frame(minHeight: 260)
    }
}
