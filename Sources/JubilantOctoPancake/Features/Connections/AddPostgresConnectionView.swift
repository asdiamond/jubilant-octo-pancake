import SwiftUI

struct AddPostgresConnectionView: View {
    @Environment(\.dismiss) private var dismiss

    var onSave: (PostgresConnectionDraft) throws -> Void

    @State private var draft = PostgresConnectionDraft()
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Add PostgreSQL Connection")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Connection details are stored locally. The password is saved in Keychain.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Form {
                TextField("Connection name", text: $draft.name)
                TextField("Host", text: $draft.host)

                HStack {
                    TextField("Port", text: $draft.port)
                        .frame(width: 96)
                    TextField("Database", text: $draft.database)
                }

                TextField("Username", text: $draft.username)
                SecureField("Password", text: $draft.password)
            }
            .formStyle(.grouped)

            if let errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundStyle(.red)
            }

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Save") {
                    save()
                }
                .disabled(!draft.isValid)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 480)
    }

    private func save() {
        do {
            try onSave(draft)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
