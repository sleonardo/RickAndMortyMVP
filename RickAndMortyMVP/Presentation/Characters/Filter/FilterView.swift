//
//  FilterView.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import SwiftUI
import RickMortySwiftApi

// MARK: - Filters View
struct FiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CharactersViewModel
    
    private var selectedStatus: Binding<Status?> {
        Binding(
            get: { viewModel.filters.status },
            set: { viewModel.filters.status = $0 }
        )
    }
    
    private var selectedGender: Binding<Gender?> {
        Binding(
            get: { viewModel.filters.gender },
            set: { viewModel.filters.gender = $0 }
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Status")) {
                    Picker("Select Status", selection: selectedStatus) {
                        Text("All").tag(Optional<Status>.none)
                        ForEach(Status.filterCasesStatus, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(Optional(status))
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Gender")) {
                    Picker("Select Gender", selection: selectedGender) {
                        Text("All").tag(Optional<Gender>.none)
                        ForEach(Gender.filterCasesGender, id: \.self) { gender in
                            Text(gender.rawValue.capitalized).tag(Optional(gender))
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                if selectedStatus.wrappedValue != nil || selectedGender.wrappedValue != nil {
                    Section(header: Text("Current Selection")) {
                        if let status = selectedStatus.wrappedValue {
                            HStack {
                                Text("Status:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(status.rawValue.capitalized)
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        if let gender = selectedGender.wrappedValue {
                            HStack {
                                Text("Gender:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(gender.rawValue.capitalized)
                                    .foregroundColor(.blue)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Apply Filters") {
                        print("🎯 Applying filters from FiltersView - Status: \(selectedStatus.wrappedValue?.rawValue ?? "None"), Gender: \(selectedGender.wrappedValue?.rawValue ?? "None")")
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    if selectedStatus.wrappedValue != nil || selectedGender.wrappedValue != nil {
                        Button("Reset Filters") {
                            print("🔄 Resetting filters from FiltersView")
                            selectedStatus.wrappedValue = nil
                            selectedGender.wrappedValue = nil
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        print("❌ Canceling filters selection")
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        print("🎯 Applying filters from toolbar - Status: \(selectedStatus.wrappedValue?.rawValue ?? "None"), Gender: \(selectedGender.wrappedValue?.rawValue ?? "None")")
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                print("📱 FiltersView appeared - Current filters: Status: \(viewModel.filters.status?.rawValue ?? "None"), Gender: \(viewModel.filters.gender?.rawValue ?? "None")")
            }
            .onDisappear {
                print("📱 FiltersView disappeared")
            }
        }
    }
}
