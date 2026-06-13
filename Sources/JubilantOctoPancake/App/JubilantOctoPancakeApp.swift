import SwiftUI

@main
struct JubilantOctoPancakeApp: App {
    var body: some Scene {
        WindowGroup {
            WorkbenchView()
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(after: .newItem) {
                Button("New Query") {
                    NotificationCenter.default.post(name: .newQueryRequested, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }

        Settings {
            SettingsView()
        }
    }
}

extension Notification.Name {
    static let newQueryRequested = Notification.Name("newQueryRequested")
}
