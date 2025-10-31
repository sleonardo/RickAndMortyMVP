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
    
    private var hasSelectedFilters: Bool {
        selectedStatus.wrappedValue != nil || selectedGender.wrappedValue != nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.rickAndMortyGradient()
                
                Form {
                    statusPicker
                    
                    genderPicker
                    
                    if hasSelectedFilters {
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
                        actionsSection.padding(.bottom, 20)
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
    
    private var actionsSection: some View {
        ActionsView(
            hasSelectedFilters: hasSelectedFilters,
            onApply: {
                print("🎯 Applying filters from FiltersView - Status: \(selectedStatus.wrappedValue?.rawValue ?? "None"), Gender: \(selectedGender.wrappedValue?.rawValue ?? "None")")
                dismiss()
            },
            onReset: {
                print("🔄 Resetting filters from FiltersView")
                selectedStatus.wrappedValue = nil
                selectedGender.wrappedValue = nil
            }
        )
        .listRowInsets(EdgeInsets())
        .background(Color.clear)
    }
    
    private var statusPicker: some View {
        FilterPickerSection(
            title: String(localized: "status_title"),
            items: Status.filterCasesStatus,
            selectedItem: selectedStatus
        )
    }
    
    private var genderPicker: some View {
        FilterPickerSection(
            title: String(localized: "gender_title"),
            items: Gender.filterCasesGender,
            selectedItem: selectedGender
        )
    }
}
