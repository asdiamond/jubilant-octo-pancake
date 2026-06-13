import Foundation

struct QueryDocument: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var sql: String
}

extension QueryDocument {
    static let sampleData: [QueryDocument] = [
        QueryDocument(
            title: "Customer Revenue",
            sql: """
            select
              customer_id,
              sum(total_cents) / 100.0 as revenue
            from orders
            where created_at >= current_date - interval '30 days'
            group by customer_id
            order by revenue desc
            limit 100;
            """
        )
    ]
}
