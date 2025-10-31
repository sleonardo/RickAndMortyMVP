//
//  FilterPickerSection.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 31/10/25.
//

import SwiftUI

// MARK: - Filter Picker Section Component
struct FilterPickerSection<T: Hashable>: View {
    let title: String
    let items: [T]
    let selectedItem: Binding<T?>
    let allText: String = String(localized: "all_text")
    let backgroundColor: Color = Color(.systemGray6).opacity(0.5)
    
    var body: some View {
        Section(header: Text(title)) {
            Picker(allText, selection: selectedItem) {
                Text(allText).tag(Optional<T>.none)
                ForEach(items, id: \.self) { item in
                    Text(String(describing: item).capitalized).tag(Optional(item))
                }
            }
            .pickerStyle(.segmented)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .listRowBackground(backgroundColor)
    }
}
