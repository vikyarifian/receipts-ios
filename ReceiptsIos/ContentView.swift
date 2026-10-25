import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExpenseReceipt.createdAt, order: .reverse) private var receipts: [ExpenseReceipt]
    
    @State private var isShowingScanner = false
    @State private var isShowingClaimSummary = false
    @State private var selectedCategoryFilter: String = "Semua"
    
    private var categories: [String] {
        ["Semua"] + ExpenseCategory.allCases.map { $0.rawValue }
    }
    
    // Workaround for SwiftData limitation where filtering dynamic enum rawValue inside @Query Predicate causes compilation failure in Swift 6
    private var filteredReceipts: [ExpenseReceipt] {
        if selectedCategoryFilter == "Semua" {
            return receipts
        }
        return receipts.filter { $0.category.rawValue == selectedCategoryFilter }
    }
    
    private var totalClaimAmount: Double {
        receipts.filter { $0.isSelectedForClaim }.reduce(0) { $0 + $1.nominalAmount }
    }
    
    private var selectedClaimCount: Int {
        receipts.filter { $0.isSelectedForClaim }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategoryFilter = category
                            }) {
                                Text(category)
                                    .font(.subheadline)
                                    .fontWeight(selectedCategoryFilter == category ? .semibold : .regular)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedCategoryFilter == category ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(selectedCategoryFilter == category ? .white : .primary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGroupedBackground))
                
                if filteredReceipts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Belum Ada Struk")
                            .font(.headline)
                        Text("Pindai struk belanja atau bahan bakar Anda agar tidak pudar saat diajukan reimburse.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button(action: {
                            isShowingScanner = true
                        }) {
                            Label("Pindai Struk Baru", systemImage: "camera.fill")
                                .font(.body.weight(.semibold))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    List {
                        ForEach(filteredReceipts) { receipt in
                            NavigationLink(destination: ReceiptDetailView(receipt: receipt)) {
                                HStack(spacing: 12) {
                                    Button(action: {
                                        toggleClaimSelection(receipt)
                                    }) {
                                        Image(systemName: receipt.isSelectedForClaim ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundColor(receipt.isSelectedForClaim ? .green : .gray)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(receipt.vendorName)
                                            .font(.headline)
                                        
                                        HStack {
                                            Text(receipt.category.rawValue)
                                                .font(.caption)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.blue.opacity(0.1))
                                                .foregroundColor(.blue)
                                                .cornerRadius(4)
                                            
                                            Text(receipt.transactionDate.formatted(date: .numeric, time: .omitted))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Text(formatRupiah(receipt.nominalAmount))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                        .onDelete(perform: deleteReceipts)
                    }
                    .listStyle(.insetGrouped)
                }
                
                if !receipts.isEmpty {
                    VStack(spacing: 8) {
                        Divider()
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(selectedClaimCount) Struk Dipilih")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(formatRupiah(totalClaimAmount))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                isShowingClaimSummary = true
                            }) {
                                Label("Ajukan Klaim", systemImage: "doc.richtext")
                                    .font(.headline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(selectedClaimCount > 0 ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(selectedClaimCount == 0)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Pengajuan Struk")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isShowingScanner = true
                    }) {
                        Image(systemName: "camera.badge.ellipsis")
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                ScannerView()
            }
            .sheet(isPresented: $isShowingClaimSummary) {
                ClaimSummaryView()
            }
        }
    }
    
    private func toggleClaimSelection(_ receipt: ExpenseReceipt) {
        receipt.isSelectedForClaim.toggle()
        try? modelContext.save()
    }
    
    private func deleteReceipts(at offsets: IndexSet) {
        let store = ExpenseStore(modelContext: modelContext)
        let receiptsToDelete = offsets.map { filteredReceipts[$0] }
        for receipt in receiptsToDelete {
            try? store.deleteReceipt(receipt)
        }
    }
    
    private func formatRupiah(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp \(Int(amount))"
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ExpenseReceipt.self, inMemory: true)
}
