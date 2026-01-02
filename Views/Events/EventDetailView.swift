//
//  EventDetailView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI
import MapKit
import FirebaseAuth

struct EventDetailView: View {
        
        // MARK: properties
        let event: Event
        
        @Environment(\.dismiss) var dismiss
        @Environment(EventListViewModel.self) var eventListViewModel
        
        @State private var showEditSheet = false
        
        //MARK: Computed Properties
        var isParticipating: Bool {
                guard let currentUserId = Auth.auth().currentUser?.uid else { return false }
                
                if let liveEvent = eventListViewModel.events.first(where: { $0.id == event.id }) {
                        return liveEvent.attendees.contains(currentUserId)
                }
                return false
        }
        
        // Participants
        var attendeesCount: Int {
                if let liveEvent = eventListViewModel.events.first(where: { $0.id == event.id }) {
                        return liveEvent.attendees.count
                }
                return event.attendees.count
        }
        
        // Message formaté pour le partage
        var shareMessage: String {
                return """
                📅 Je t'invite à l'événement : \(event.title) !
                📍 Lieu : \(event.location)
                ⏰ Date : \(event.date.formatted(date: .long, time: .shortened))
                
                Rejoins-nous sur Eventorias !
                """
        }
        
        
        // MARK: body
        var body: some View {
                ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                                
                                // IMAGE
                                Group {
                                        if let imageURL = event.imageURL, let url = URL(string: imageURL) {
                                                
                                                AsyncImage(url: url) { phase in
                                                        switch phase {
                                                        case .empty:
                                                                ZStack {
                                                                        Color(white: 0.1)
                                                                        ProgressView()
                                                                }
                                                        case .success(let image):
                                                                image
                                                                        .resizable()
                                                                        .aspectRatio(contentMode: .fill)
                                                        case .failure:
                                                                Image(event.category.assetName) // Fallback si erreur téléchargement
                                                                        .resizable()
                                                                        .aspectRatio(contentMode: .fill)
                                                        @unknown default:
                                                                EmptyView()
                                                        }
                                                }
                                        } else {
                                                Image(event.category.assetName)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                        }
                                }
                                .frame(height: 300)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                
                                // Date/Heure/Avatar
                                HStack(alignment: .center) {
                                        VStack(alignment: .leading, spacing: 8) {
                                                /// Date
                                                HStack {
                                                        Image(systemName: "calendar")
                                                                .foregroundStyle(.white)
                                                        Text(event.date.formatted(.dateTime.year().month(.wide).day()))
                                                                .foregroundStyle(.white)
                                                }
                                                /// Heure
                                                HStack {
                                                        Image(systemName: "clock")
                                                                .foregroundStyle(.white)
                                                        
                                                        Text(event.date.formatted(date: .omitted, time: .shortened))
                                                                .foregroundStyle(.white)
                                                }
                                        }
                                        .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        /// Avatar (Exemple statique pour l'instant)
                                        Image("Avatar (3)") // Assure-toi que cette image existe
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 60, height: 60)
                                                .clipShape(Circle())
                                                .shadow(radius: 5)
                                }
                                
                                /// Description
                                Text(event.description)
                                        .font(.body)
                                        .foregroundStyle(.gray)
                                        .lineSpacing(5)
                                
                                /// Compteur de participants & Bouton
                                HStack(spacing: 0) {
                                        
                                        HStack(spacing: 4) {
                                                Image(systemName: "person.2.fill")
                                                        .font(.subheadline)
                                                
                                                // CORRECTION : On utilise le compteur dynamique
                                                Text("\(attendeesCount)")
                                                        .font(.headline)
                                                        .fontWeight(.bold)
                                        }
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(white: 0.2))
                                        .clipShape(Capsule())
                                        
                                        Text(" participants")
                                                .font(.subheadline)
                                                .foregroundStyle(.gray)
                                                .padding(.leading, 8)
                                        
                                        Spacer()
                                        
                                        // BOUTON PARTICIPER
                                        Button {
                                                // Feedback Haptique (Vibration légère)
                                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                                generator.impactOccurred()
                                                
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                                        eventListViewModel.toggleParticipation(event: event)
                                                }
                                        } label: {
                                                HStack(spacing: 6) {
                                                        Image(systemName: isParticipating ? "checkmark.circle.fill" : "ticket.fill")
                                                                .font(.title3)
                                                        Text(isParticipating ? "Inscrit(e)" : "Participer")
                                                                .font(.headline)
                                                                .fontWeight(.bold)
                                                }
                                                .font(.subheadline)
                                                .frame(width: 140, height: 45) // Un peu plus grand pour être cliquable
                                                .background(isParticipating ? Color(white: 0.2) : Color.blue) // Bleu quand on peut rejoindre
                                                .foregroundStyle(.white)
                                                .clipShape(Capsule())
                                                .shadow(color: isParticipating ? .clear : .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                                        }
                                        .padding(.vertical, 5)
                                }
                                
                                .padding(.vertical, 5)
                                
                                Spacer()
                                
                                // ADRESSE & MAP
                                HStack (alignment: .top, spacing: 15) {
                                        
                                        VStack(alignment: .leading, spacing: 1) {
                                                // Adresse
                                                Text(event.location)
                                                        .font(.headline)
                                                        .foregroundStyle(.white)
                                                        .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .padding(.top, 8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        // Map Dynamique
                                        // CORRECTION : On utilise les vraies coordonnées de l'event !
                                        Map(initialPosition: .region(MKCoordinateRegion(
                                                center: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude),
                                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        ))) {
                                                Marker(event.location, coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude))
                                        }
                                        .frame(width: 130, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .disabled(true)
                                }
                                .padding(.bottom, 80)
                        }
                        .padding()
                }
                
                .toolbar {
                        // Bouton partager
                                    ToolbarItem(placement: .topBarTrailing) {
                                        ShareLink(item: shareMessage) {
                                            Image(systemName: "square.and.arrow.up")
                                                .foregroundStyle(.blue)
                                        }
                                    }
                        // Bouton modifier
                        if let currentUserId = eventListViewModel.currentUserId,
                           event.userId == currentUserId {
                                
                                ToolbarItem(placement: .topBarTrailing) {
                                        Button("Modifier") {
                                                showEditSheet.toggle()
                                        }
                                        .tint(.white)
                                }
                        }
                }
                .sheet(isPresented: $showEditSheet) {
                        EditEventView(event: event)
                }
                .background(Color.black.ignoresSafeArea())
                .navigationBarBackButtonHidden(false)
                .navigationTitle(event.title)
                .navigationBarTitleDisplayMode(.inline)
        }
}

// MARK: preview
#Preview {
        EventDetailView(event: Event(
                userId: "1",
                title: "Soirée Test",
                description: "Ceci est une description de test pour voir si tout s'affiche bien.",
                date: Date(),
                location: "Tour Eiffel, Paris",
                category: .sport,
                attendees: ["user1", "user2"],
                imageURL: nil,
                latitude: 48.8584,
                longitude: 2.2945
        ))
        .environment(EventListViewModel())
}
