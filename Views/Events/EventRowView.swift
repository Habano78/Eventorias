//
//  EventRowView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct EventRowView: View {
       
        //MARK: dependence
        let event: Event
        
        //MARK: body
        var body: some View {
                
                HStack(spacing: 15) {
                        
                        // User Image
                        Image("Avatar (1)")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        
                        // Infos
                        VStack(alignment: .leading, spacing: 5) {
                                Text(event.title)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                
                                Text(event.date.formatted(date: .long, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        // Event Image
                        Image(event.category.assetName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
                .background(Color(white: 0.2))
                .cornerRadius(15)
        }
}

//MARK: preview
#Preview {
        EventRowView(event: Event(userId: "1", title: "Test Event", description: "", date: Date(), location: "Paris", category: .food))
                .padding()
                .background(Color.black)
}
