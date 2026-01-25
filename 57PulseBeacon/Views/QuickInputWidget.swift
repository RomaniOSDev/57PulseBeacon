//
//  QuickInputWidget.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI

struct QuickInputWidget: View {
    @ObservedObject var viewModel: ActiveBeaconViewModel
    @Binding var isPresented: Bool
    @State private var inputValue: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Quick Input")
                .font(.headline)
            
            TextField("Enter value", text: $inputValue)
                .font(.system(size: 40, weight: .bold))
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .focused($isFocused)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            
            HStack(spacing: 16) {
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                Button("Save") {
                    viewModel.updateValue(inputValue)
                    isPresented = false
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "#FF3C00"))
                .cornerRadius(12)
                .disabled(inputValue.isEmpty)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .onAppear {
            isFocused = true
            if let lastValue = viewModel.lastValue {
                inputValue = String(format: "%.1f", lastValue)
            }
        }
    }
}
