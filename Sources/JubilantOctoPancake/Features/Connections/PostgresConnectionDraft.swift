import Foundation

struct PostgresConnectionDraft {
    var name = ""
    var host = "localhost"
    var port = "5432"
    var database = ""
    var username = NSUserName()
    var password = ""

    var normalizedPort: Int? {
        Int(port.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedHost: String {
        host.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedDatabase: String {
        database.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedUsername: String {
        username.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isValid: Bool {
        !trimmedName.isEmpty
            && !trimmedHost.isEmpty
            && normalizedPort != nil
            && !trimmedDatabase.isEmpty
            && !trimmedUsername.isEmpty
    }
}
