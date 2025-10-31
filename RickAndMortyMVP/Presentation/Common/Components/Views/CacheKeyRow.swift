//
//  CacheKeyRow.swift
//  RickAndMortyMVP
//
//  Created by Leonardo Simoza on 31/10/25.
//

import SwiftUICore

struct CacheKeyRow: View {
    let key: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.caption)
                .foregroundColor(.orange)
                .frame(width: 20)
            
            Text(key)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.middle)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}
