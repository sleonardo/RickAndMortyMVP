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
    
    @State private var selectedStatus: Status?
    @State private var selectedGender: Gender?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Status")) {
                    Picker("Select Status", selection: $selectedStatus) {
                        Text("All").tag(Optional<Status>.none)
                        ForEach(Status.filterCasesStatus, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(Optional(status))
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Gender")) {
                    Picker("Select Gender", selection: $selectedGender) {
                        Text("All").tag(Optional<Gender>.none)
                        ForEach(Gender.filterCasesGender, id: \.self) { gender in
                            Text(gender.rawValue.capitalized).tag(Optional(gender))
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button("Apply Filters") {
                        viewModel.applyFilters(status: selectedStatus, gender: selectedGender)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Button("Reset Filters") {
                        selectedStatus = nil
                        selectedGender = nil
                        viewModel.applyFilters(status: nil, gender: nil)
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // Initialize with current filters
                selectedStatus = viewModel.filters.status
                selectedGender = viewModel.filters.gender
            }
        }
    }
}
