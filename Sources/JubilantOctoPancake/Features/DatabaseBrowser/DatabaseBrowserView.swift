import SwiftUI

struct DatabaseBrowserView: View {
    let objects: [DatabaseObject]
    @Binding var selectedObjectID: DatabaseObject.ID?

    var body: some View {
        List(selection: $selectedObjectID) {
            Section("Database") {
                ForEach(objects) { object in
                    HStack(spacing: 8) {
                        Image(systemName: iconName(for: object.kind))
                            .frame(width: 18)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(object.name)
                            Text(subtitle(for: object))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 3)
                    .tag(object.id)
                }
            }
        }
        .navigationTitle("Objects")
        .navigationSplitViewColumnWidth(min: 240, ideal: 300)
    }

    private func iconName(for kind: DatabaseObject.Kind) -> String {
        switch kind {
        case .schema:
            return "square.stack.3d.up"
        case .table:
            return "tablecells"
        case .view:
            return "eye"
        case .function:
            return "function"
        }
    }

    private func subtitle(for object: DatabaseObject) -> String {
        if let rowEstimate = object.rowEstimate {
            return "\(object.kind.rawValue) - \(rowEstimate.formatted()) rows"
        }

        return object.kind.rawValue
    }
}
