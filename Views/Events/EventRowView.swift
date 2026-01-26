//
//  EventRowView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct EventRowView: View {
        
        let event: Event
        
        var body: some View {
                HStack(spacing: 12) {
                        
                        // Image
                        if let urlString = event.imageURL, let url = URL(string: urlString) {
                                AsyncImage(url: url) { image in
                                        image.resizable().aspectRatio(contentMode: .fill)
                                } placeholder: {
                                        Color.gray.opacity(0.3)
                                }
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                        } else {
                                Image(event.category.assetName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 70, height: 70)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Texte
                        VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.primary)
                                        .lineLimit(2)
                                
                                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                
                                Text(event.location)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                        }
                        
                        Spacer()
                }
                .padding(.vertical, 8)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Événement \(event.title), le \(event.date.formatted(date: .long, time: .omitted)) à \(event.location)")
                .accessibilityHint("Double-tapez pour voir les détails")
                .accessibilityAddTraits(.isButton)
        }
}
