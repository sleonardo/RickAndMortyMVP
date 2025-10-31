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
            ZStack {
                Color.clear.rickAndMortyGradient()
                
                Form {
                    Section(header: Text(String(localized:"status_title"))) {
                        Picker(String(localized:"select_status_text"), selection: selectedStatus) {
                            Text(String(localized:"all_text")).tag(Optional<Status>.none)
                            ForEach(Status.filterCasesStatus, id: \.self) { status in
                                Text(status.rawValue.capitalized).tag(Optional(status))
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Section(header: Text(String(localized:"gender_title"))) {
                        Picker(String(localized:"select_gender_text"), selection: selectedGender) {
                            Text(String(localized:"all_text")).tag(Optional<Gender>.none)
                            ForEach(Gender.filterCasesGender, id: \.self) { gender in
                                Text(gender.rawValue.capitalized).tag(Optional(gender))
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    if selectedStatus.wrappedValue != nil || selectedGender.wrappedValue != nil {
                        Section(header: Text(String(localized:"current_selection_text"))) {
                            if let status = selectedStatus.wrappedValue {
                                HStack {
                                    Text(String(localized:"status_text"))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(status.rawValue.capitalized)
                                        .foregroundColor(.blue)
                                        .fontWeight(.semibold)
                                }
                            }
                            
                            if let gender = selectedGender.wrappedValue {
                                HStack {
                                    Text(String(localized:"gender_text"))
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
                        Button(String(localized:"apply_filters_button")) {
                            print("🎯 Applying filters from FiltersView - Status: \(selectedStatus.wrappedValue?.rawValue ?? "None"), Gender: \(selectedGender.wrappedValue?.rawValue ?? "None")")
                            
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            
                            dismiss()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        if selectedStatus.wrappedValue != nil || selectedGender.wrappedValue != nil {
                            Button(String(localized:"reset_filters_button")) {
                                print("🔄 Resetting filters from FiltersView")
                                
                                let impactLight = UIImpactFeedbackGenerator(style: .light)
                                impactLight.impactOccurred()
                                
                                selectedStatus.wrappedValue = nil
                                selectedGender.wrappedValue = nil
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle(String(localized:"filter_navigation_title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized:"cancel_button")) {
                        print("❌ Canceling filters selection")
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized:"apply_button")) {
                        print("🎯 Applying filters from toolbar - Status: \(selectedStatus.wrappedValue?.rawValue ?? "None"), Gender: \(selectedGender.wrappedValue?.rawValue ?? "None")")
                        
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                        
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
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
