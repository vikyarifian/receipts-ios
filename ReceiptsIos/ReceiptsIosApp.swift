import SwiftUI
import SwiftData

@main
struct ReceiptsIosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ExpenseReceipt.self)
    }
}
