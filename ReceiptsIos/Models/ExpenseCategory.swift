import Foundation
import SwiftUI

extension ExpenseCategory {
    var iconName: String {
        switch self {
        case .bensin:
            return "fuelpump.fill"
        case .parkir:
            return "car.fill"
        case .konsumsi:
            return "fork.knife"
        case .tol:
            return "road.lanes"
        case .operasional:
            return "briefcase.fill"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .bensin:
            return .orange
        case .parkir:
            return .blue
        case .konsumsi:
            return .green
        case .tol:
            return .purple
        case .operasional:
            return .gray
        }
    }
}
