import SwiftUI

struct SettingsView: View {
    @AppStorage("queryFontSize") private var queryFontSize = 13.0
    @AppStorage("runQueriesInTransaction") private var runQueriesInTransaction = true

    var body: some View {
        Form {
            Section("Query Editor") {
                Slider(value: $queryFontSize, in: 11...20, step: 1) {
                    Text("Font size")
                } minimumValueLabel: {
                    Text("11")
                } maximumValueLabel: {
                    Text("20")
                }

                Toggle("Run write queries inside a transaction by default", isOn: $runQueriesInTransaction)
            }
        }
        .padding(24)
        .frame(width: 440)
    }
}
