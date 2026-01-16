//
//  EventRowView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct EventRowView: View {
        
        // MARK: Properties
        let event: Event
        
        // MARK: Body
        var body: some View {
                
                HStack(spacing: 0) {
                        
                        HStack(spacing: 12) {
                                
                                Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(.gray)
                                        .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 4) {
                                        
                                        Text(event.title)
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.white)
                                                .lineLimit(2)
                                        
                                        Text(event.date.formatted(.dateTime.year().month(.wide).day()))
                                                .font(.subheadline)
                                                .foregroundStyle(.gray)
                                }
                        }
                        .padding(14)
                        
                        Spacer()
                        
                        Image(event.category.assetName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 90)
                                .clipped()
                                .background(Color(white: 0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel("Événement \(event.title), le \(event.date.formatted(date: .long, time: .omitted)), à \(event.location)")
                                .accessibilityHint("Double-tapez pour voir les détails")
                                .accessibilityAddTraits(.isButton)
                }
        }
}
