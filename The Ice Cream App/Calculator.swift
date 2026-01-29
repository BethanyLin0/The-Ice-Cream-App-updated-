//
//  Calculator.swift
//  Ice Cream
//
//  Created by Bethany on 2025/3/5.
//
import SwiftUI

struct Calculator: View {
    @State private var displayValue = "0"
    @State private var runningNumber = 0
    @State private var currentOp: Operation = .none
    @State private var enteringNewNumber = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Display Area: Fills available vertical space and scales text
            Text(displayValue)
                .font(.system(size: 80, weight: .thin, design: .rounded))
                .minimumScaleFactor(0.2) // Prevents text clipping on small windows
                .lineLimit(1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .padding()
                .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                .shadow(color: .black.opacity(0.05), radius: 10)
            
            // Grid Layout: Set to fill remaining space
            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                // Row 1: AC and Delete filling 3 columns
                GridRow {
                    HStack(spacing: 12) {
                        calcButton(label: "AC", color: .orange)
                        calcButton(label: "⌫", color: .orange)
                    }
                    .gridCellColumns(3)
                    calcButton(label: "÷", color: .darkGreen)
                }
                
                // Rows 2-4: Standard Numbers
                GridRow {
                    calcButton(label: "7"); calcButton(label: "8"); calcButton(label: "9")
                    calcButton(label: "×", color: .darkGreen)
                }
                GridRow {
                    calcButton(label: "4"); calcButton(label: "5"); calcButton(label: "6")
                    calcButton(label: "−", color: .darkGreen)
                }
                GridRow {
                    calcButton(label: "1"); calcButton(label: "2"); calcButton(label: "3")
                    calcButton(label: "+", color: .darkGreen)
                }
                
                // Row 5: 0 spans 3 columns to remove the gap
                GridRow {
                    calcButton(label: "0")
                        .gridCellColumns(3)
                    calcButton(label: "=", color: .darkGreen)
                }
            }
            .frame(maxHeight: .infinity) // Grid stretches to fill the window
        }
        .padding(20)
        .background(Color(red: 0.72, green: 0.9, blue: 0.66).opacity(0.2))
    }
    
    // MARK: - Button Builder
    @ViewBuilder
    private func calcButton(label: String, color: ButtonType = .standard) -> some View {
        Button(action: { handlePress(label) }) {
            Text(label)
                .font(.title2)
            // maxHeight: .infinity allows buttons to grow vertically with the window
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(getBG(color))
                .foregroundColor(getFG(color))
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helper Logic
    enum ButtonType { case standard, darkGreen, orange }
    
    private func getBG(_ type: ButtonType) -> Color {
        switch type {
        case .standard: return .white
        case .darkGreen: return Color(red: 0.04, green: 0.43, blue: 0.25)
        case .orange: return Color.orange.opacity(0.1)
        }
    }
    
    private func getFG(_ type: ButtonType) -> Color {
        return type == .darkGreen ? .white : (type == .orange ? .orange : .primary)
    }
    
    private func handlePress(_ label: String) {
        if let _ = Int(label) {
            if displayValue == "0" || enteringNewNumber {
                displayValue = label
                enteringNewNumber = false
            } else {
                displayValue += label
            }
        } else {
            switch label {
            case "AC":
                displayValue = "0"
                runningNumber = 0
                currentOp = .none
            case "⌫":
                if displayValue.count > 1 { displayValue.removeLast() }
                else { displayValue = "0" }
            case "+": setOp(.add)
            case "−": setOp(.subtract)
            case "×": setOp(.multiply)
            case "÷": setOp(.divide)
            case "=": calculateResult()
            default: break
            }
        }
    }
    
    private func setOp(_ op: Operation) {
        runningNumber = Int(displayValue) ?? 0
        currentOp = op
        enteringNewNumber = true
    }
    
    private func calculateResult() {
        let current = Int(displayValue) ?? 0
        // Fix: Exhaustive switch handling all Operation cases
        switch currentOp {
        case .add:
            displayValue = "\(runningNumber + current)"
        case .subtract:
            displayValue = "\(runningNumber - current)"
        case .multiply:
            displayValue = "\(runningNumber * current)"
        case .divide:
            displayValue = current == 0 ? "Error" : "\(runningNumber / current)"
        case .none, .equal:
            break
        }
        enteringNewNumber = true
    }
}

enum Operation {
    case add, subtract, multiply, divide, equal, none
}


#Preview {
    Calculator()
}
