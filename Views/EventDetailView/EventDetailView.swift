//
//  EventDetailView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct EventDetailView: View {
        
        
        let event: Event
        
        var body: some View {
                ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                                // Image d'en-tête
                                Image(getDetailImageName(for: event.category))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 250)
                                        .clipped() // Pour éviter que l'image déborde
                                
                                VStack(alignment: .leading, spacing: 16) {
                                        // Titre et Date
                                        VStack(alignment: .leading, spacing: 8) {
                                                Text(event.title)
                                                        .font(.title)
                                                        .fontWeight(.bold)
                                                
                                                HStack {
                                                        Image(systemName: "calendar")
                                                                .foregroundStyle(.blue)
                                                        Text(event.date.formatted(date: .long, time: .shortened))
                                                                .foregroundStyle(.secondary)
                                                }
                                        }
                                        
                                        Divider()
                                        
                                        // Description
                                        VStack(alignment: .leading, spacing: 8) {
                                                Text("À propos")
                                                        .font(.headline)
                                                Text(event.description)
                                                        .font(.body)
                                                        .foregroundStyle(.secondary)
                                        }
                                        
                                        Divider()
                                        
                                        // Lieu
                                        HStack {
                                                Image(systemName: "map.fill")
                                                        .foregroundStyle(.red)
                                                Text(event.location)
                                        }
                                        
                                        // Participants
                                        VStack(alignment: .leading, spacing: 8) {
                                                Text("Participants")
                                                        .font(.headline)
                                                HStack(spacing: -10) { // Chevauchement des avatars
                                                        ForEach(1...5, id: \.self) { index in
                                                                Image("Avatar (\(index))") // Utilise vos assets "Avatar (1)", etc.
                                                                        .resizable()
                                                                        .scaledToFill()
                                                                        .frame(width: 40, height: 40)
                                                                        .clipShape(Circle())
                                                                        .overlay(Circle().stroke(.white, lineWidth: 2))
                                                        }
                                                }
                                        }
                                }
                                .padding()
                        }
                }
                .ignoresSafeArea(edges: .top)
                .navigationBarTitleDisplayMode(.inline)
        }
        
        // Helper pour choisir l'image 
        func getDetailImageName(for category: EventCategory) -> String {
                switch category {
                case .art: return "Event DetailArtExhibition"
                case .music: return "Event MusicFestival"
                case .charity: return "Event CarityRun"
                default: return "Event TechConf"
                }
        }
}

#Preview {
        // Donnée bidon pour la preview
        EventDetailView(event: Event(
                userId: "1",
                title: "Test Event",
                description: "Description de test",
                date: Date(),
                location: "Paris",
                category: .art
        ))
}
