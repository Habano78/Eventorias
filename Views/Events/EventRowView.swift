//
//  EventRowView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct EventRowView: View {
        
        //MARK: properties
        let event: Event
        
        private var formattedDate: String {
                event.date.formatted(date: .long, time: .omitted)
        }
        
        //MARK: body
        var body: some View {
                
                HStack(spacing: 0) {
                        
                        // Avatar/Titre/Date
                        HStack(spacing: 12) {
                                
                                Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 10) {
                                        
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
                        
                        // Event Image
                        Image(event.category.assetName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 130, height: 100)
                                .clipped()
                }
                .background(Color(white: 0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
        }
}
