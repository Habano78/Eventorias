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
        
        //MARK: properties
        let event: Event
        @Environment(\.dismiss) var dismiss
        @Environment(EventListViewModel.self) var viewModel
        
        var isParticipating: Bool {
                guard let currentUserId = Auth.auth().currentUser?.uid else { return false }
                return event.attendees.contains(currentUserId)
        }
        
        
        //MARK: body
        var body: some View {
                ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                                
                                // Image
                                Image(event.category.assetName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
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
                                        
                                        /// Avatar
                                        Image("Avatar (3)")
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
                               
                                /// Compteur de participants
                                HStack(spacing: 10) {
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "person.2.fill")
                                                            .font(.subheadline)
                                                        
                                                        Text("\(event.attendees.count)")
                                                            .font(.headline)
                                                            .fontWeight(.bold)
                                                    }
                                                    .foregroundStyle(.white)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 8)
                                                    .background(Color(white: 0.2))
                                                    .clipShape(Capsule())
                                                    
                                                    Text("participant(s)")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.gray)
                                       
                                        
                                        Button {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                                        viewModel.toggleParticipation(event: event)
                                                }
                                        } label: {
                                                HStack(spacing: 12) {
                                                        Image(systemName: isParticipating ? "checkmark.circle.fill" : "ticket.fill")
                                                                .font(.title3)
                                                        Text(isParticipating ? "Inscrit(e)" : "Participer")
                                                                .font(.headline)
                                                                .fontWeight(.bold)
                                                }
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 35)
                                                .frame(width: 150, alignment: .init(horizontal: .center, vertical: .center))
                                                .background(isParticipating ? Color(white: 0.2) : Color.blue)
                                                .foregroundStyle(.white)
                                                .clipShape(Capsule())
                                                .shadow(color: isParticipating ? .clear : .red.opacity(0.4), radius: 10, x: 0, y: 5)
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 10)
                
                                                }
                                
                                                .padding(.vertical, 5)
                                Spacer()
                                
                                // Adresse/Map
                                HStack (alignment: .top, spacing: 15) {
                                        
                                        VStack(alignment: .leading, spacing: 1) {
                                                /// adresse
                                                Text(event.location)
                                                        .font(.headline)
                                                        .foregroundStyle(.white)
                                                        .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .padding(.top, 8)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        ///Map
                                        Map(initialPosition: .region(MKCoordinateRegion(
                                                center: CLLocationCoordinate2D(latitude: 23.1136, longitude: -82.3666),
                                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        )))
                                        .frame(width: 140, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .disabled(true)
                                }
                                .padding()
                                .padding(.bottom, 80)
                        }
                        .padding()
                }
                .background(Color.black.ignoresSafeArea())
                .navigationBarBackButtonHidden(true)
        }
}
//MARK: previw
#Preview {
        EventDetailView(event: Event(
                userId: "1",
                title: "Test Event",
                description: "Description de test pour la preview...",
                date: Date(),
                location: "Paris",
                category: .charity
        ))
        .environment(EventListViewModel())
}

