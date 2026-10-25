import Foundation
import SwiftData

enum ExpenseCategory: String, Codable, CaseIterable {
    case bensin = "Bensin / BBM"
    case parkir = "Parkir"
    case konsumsi = "Konsumsi / Client Lunch"
    case tol = "Tol"
    case operasional = "Operasional Kantor"
}

@Model
final class ExpenseReceipt {
    @Attribute(.unique) var id: UUID
    var vendorName: String
    var nominalAmount: Double
    var category: ExpenseCategory
    var transactionDate: Date
    var imageFileName: String
    var isSelectedForClaim: Bool
    var notes: String?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        vendorName: String,
        nominalAmount: Double,
        category: ExpenseCategory,
        transactionDate: Date = Date(),
        imageFileName: String,
        isSelectedForClaim: Bool = true,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.vendorName = vendorName
        self.nominalAmount = nominalAmount
        self.category = category
        self.transactionDate = transactionDate
        self.imageFileName = imageFileName
        self.isSelectedForClaim = isSelectedForClaim
        self.notes = notes
        self.createdAt = createdAt
    }
}
