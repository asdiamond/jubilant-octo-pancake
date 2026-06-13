import SwiftUI

struct ResultsPreviewView: View {
    private let rows = [
        QueryResultRow(customerID: "cus_1042", revenue: "14892.40", orders: "41"),
        QueryResultRow(customerID: "cus_2190", revenue: "11308.18", orders: "27"),
        QueryResultRow(customerID: "cus_0881", revenue: "9204.77", orders: "19")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Results")
                    .font(.headline)
                Spacer()
                Text("3 rows")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            Table(rows) {
                TableColumn("customer_id") { row in
                    Text(row.customerID)
                }
                TableColumn("revenue") { row in
                    Text(row.revenue)
                        .monospacedDigit()
                }
                TableColumn("orders") { row in
                    Text(row.orders)
                        .monospacedDigit()
                }
            }
        }
    }
}

private struct QueryResultRow: Identifiable {
    let id = UUID()
    var customerID: String
    var revenue: String
    var orders: String
}
