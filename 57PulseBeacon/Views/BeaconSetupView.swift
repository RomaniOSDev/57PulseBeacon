//
//  BeaconSetupView.swift
//  57PulseBeacon
//
//  Created by Роман Главацкий on 18.01.2026.
//

import SwiftUI

struct BeaconSetupView: View {
    @StateObject private var viewModel: BeaconSetupViewModel
    @Binding var beacon: Beacon?
    @Environment(\.dismiss) var dismiss
    
    init(beacon: Binding<Beacon?>) {
        self._beacon = beacon
        let vm = BeaconSetupViewModel()
        if let existingBeacon = beacon.wrappedValue {
            vm.selectedMetric = existingBeacon.metricName
            vm.minValue = String(format: "%.0f", existingBeacon.minValue)
            vm.maxValue = String(format: "%.0f", existingBeacon.maxValue)
            if let critical = existingBeacon.criticalThreshold {
                vm.criticalThreshold = String(format: "%.0f", critical)
            }
        }
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Metric Name")) {
                    Picker("Select Metric", selection: $viewModel.selectedMetric) {
                        ForEach(viewModel.predefinedMetrics, id: \.self) { metric in
                            Text(metric).tag(metric)
                        }
                    }
                    .onChange(of: viewModel.selectedMetric) { newValue in
                        viewModel.showCustomMetric = (newValue == "Custom")
                    }
                    
                    if viewModel.showCustomMetric {
                        TextField("Enter custom metric", text: $viewModel.customMetric)
                    }
                }
                
                Section(header: Text("Green Zone (Target Range)")) {
                    TextField("Minimum", text: $viewModel.minValue)
                        .keyboardType(.decimalPad)
                    
                    TextField("Maximum", text: $viewModel.maxValue)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Critical Threshold (Optional)")) {
                    TextField("Critical value", text: $viewModel.criticalThreshold)
                        .keyboardType(.decimalPad)
                        .foregroundColor(Color(hex: "#FF3C00"))
                }
                
                Section {
                    Button(action: {
                        if let newBeacon = viewModel.createBeacon(id: beacon?.id) {
                            beacon = newBeacon
                            dismiss()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text(beacon == nil ? "Create Beacon" : "Save Changes")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "#FF3C00"))
                    .disabled(viewModel.metricName.isEmpty || 
                             viewModel.minValue.isEmpty || 
                             viewModel.maxValue.isEmpty)
                }
            }
            .background(Color.white)
        }
    }
}
