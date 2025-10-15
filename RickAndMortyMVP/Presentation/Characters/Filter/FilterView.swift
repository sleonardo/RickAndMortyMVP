//
//  FilterView.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 15/10/25.
//

import SwiftUI
import RickMortySwiftApi

struct FilterView: View {
    @Binding var filters: Filters
    @Environment(\.dismiss) private var dismiss
    
    // Arrays for pickers
    private let statusCases: [Status] = [.alive, .dead, .unknown]
    private let genderCases: [Gender] = [.female, .male, .genderless, .unknown]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Status") {
                    Picker("Status", selection: $filters.status) {
                        Text("All").tag(nil as Status?)
                        ForEach(statusCases, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(status as Status?)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Gender") {
                    Picker("Gender", selection: $filters.gender) {
                        Text("All").tag(nil as Gender?)
                        ForEach(genderCases, id: \.self) { gender in
                            Text(gender.rawValue.capitalized).tag(gender as Gender?)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Species") {
                    TextField("Species", text: $filters.species)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section {
                    Button("Clear Filters") {
                        filters = Filters()
                    }
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
        }
    }
}
