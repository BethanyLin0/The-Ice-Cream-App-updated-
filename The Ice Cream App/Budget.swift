//
//  Budget.swift
//  Ice Cream
//
//  Created by Bethany on 2025/3/5.
//
import SwiftUI
import SwiftData

struct Budget: View {
    // Reads data from "Expense" database
    // "@Query" is used to retrieve data from database
    @Query(sort: \Expense.dateCreated, order: .reverse)
    private var expenses: [Expense]
    
    // Connects to Expense model
    @Environment(\.modelContext) private var context
    
    // Controls when an "Add Expense" sheet pops out
    @State private var showSheet = false
    
    // Controls the confirmation alert
    @State private var showingDeleteAlert = false
    
    // Calculates the total of all expenses
    private var totalSaving: Double {
        expenses.reduce(0) { $0 + $1.cost }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            
            // HEADER SECTION
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Frances' Lab")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text("Budget")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    if !expenses.isEmpty { // Only show if there is data to delete
                        Button(role: .destructive) {
                            showingDeleteAlert = true // Trigger the alert
                        } label: {
                            Label("Clear All", systemImage: "trash")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    // Button for adding new transactions
                    Button {
                        showSheet = true
                    } label: {
                        Label("Add Transaction", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.04, green: 0.43, blue: 0.25))
                }
            }
            
            Divider()
            
            // Display total expense
            HStack {
                VStack(alignment: .leading) {
                    Text("Current Balance")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    Text("$\(totalSaving, specifier:"%.2f")")
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: totalSaving >= 0 ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(totalSaving >= 0 ? Color(red: 0.04, green: 0.43, blue: 0.25) : Color.red.opacity(0.8))
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            
            // TRANSACTION LIST SECTION
            VStack(alignment: .leading) {
                Text("Recent Transactions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                
                // Only this part will scroll
                ScrollView {
                    VStack(spacing: 0) {
                        if expenses.isEmpty {
                            ContentUnavailableView("No Transactions", systemImage: "creditcard")
                                .padding(.vertical, 50)
                        } else {
                            // List each expense and pass the modelContext
                            ForEach(expenses) { exp in
                                TransactionRow(exp: exp)
                                Divider()
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(NSColor.controlBackgroundColor)))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.1), lineWidth: 1))
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // Ensures it fills the window
        .background(Color(NSColor.windowBackgroundColor))
        
        // "Delete all" button
        .alert("Delete All Transactions?", isPresented: $showingDeleteAlert) {
            Button("Delete Everything", role: .destructive) {
                deleteAllExpenses() // Call the deletion function
            }
            Button("Cancel", role: .cancel) { } // Dismisses the alert safely
        } message: {
            Text("This action cannot be undone. Are you sure you want to clear your entire budget history?")
        }
        
        .sheet(isPresented: $showSheet) {
            AddExpensesView()
                .frame(minWidth: 400, minHeight: 300)
        }
    }
    
    private func deleteAllExpenses() {
        for expense in expenses {
            context.delete(expense) // Removes each item from SwiftData
        }
    }
}

// Extracted Row View for cleaner code
struct TransactionRow: View {
    let exp: Expense
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HStack {
            Image(systemName: exp.cost < 0 ? "cart.fill" : "dollarsign.circle.fill")
                .foregroundColor(exp.cost < 0 ? .orange : .green)
                .frame(width: 30)
            
            Text(exp.name)
                .font(.headline)
            
            Spacer()
            
            Text(exp.cost < 0 ? "-$\(abs(exp.cost), specifier:"%.2f")" : "+$\(exp.cost, specifier:"%.2f")")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(exp.cost < 0 ? .primary : .green)
                .fontWeight(.semibold)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .contextMenu {
            Button(role: .destructive) {
                context.delete(exp) // Deletes only THIS specific expense
            } label: {
                Label("Delete Transaction", systemImage: "trash")
            }
        }
    }
}

// This view is for adding new expenses/income
struct AddExpensesView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var costString = ""
    @State private var selectedCategory = "Expense"
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Type", selection: $selectedCategory) {
                    Text("Expense").tag("Expense")
                    Text("Income").tag("Income")
                }
                .pickerStyle(.segmented)
                
                Section {
                    TextField("\(selectedCategory) Name", text: $name)
                    TextField("Amount", text: $costString)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Add \(selectedCategory)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveExpense() }
                        .disabled(name.isEmpty || costString.isEmpty)
                }
            }
        }
    }
    
    private func saveExpense() {
        // 1. Clean the input string and convert to Double
        let baseValue = Double(costString) ?? 0.0
        
        // 2. Apply logic: Expenses are stored as negative numbers
        let costValue = selectedCategory == "Expense" ? -abs(baseValue) : abs(baseValue)
        
        // 3. Create the new Expense object
        // This matches your @Model class Expense exactly
        let newExp = Expense(name: name, cost: costValue)
        
        // 4. Insert into the database
        context.insert(newExp)
        
        // 5. Close the sheet
        dismiss()
    }
}

#Preview {
    Budget()
}
