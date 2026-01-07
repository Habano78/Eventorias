//
//  EventMapView.swift
//  Eventorias
//
//  Created by Perez William on 28/12/2025.
//

import SwiftUI
import MapKit

struct EventMapView: View {
        
        @Environment(EventListViewModel.self) var viewModel
        
        // Position initiale
        @State private var position: MapCameraPosition = .automatic
        
        // L'événement sélectionné
        @State private var selectedEvent: Event?
        
        var body: some View {
                NavigationStack {
                        MapReader { proxy in
                                Map(position: $position, interactionModes: .all, selection: $selectedEvent) {
                                        
                                        ForEach(viewModel.events) { event in
                                                Annotation(event.title, coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)) {
                                                        ZStack {
                                                                RoundedRectangle(cornerRadius: 8)
                                                                        .fill(backgroundColor(for: event.category))
                                                                        .frame(width: 35, height: 35)
                                                                        .shadow(radius: 3)
                                                                
                                                                Image(systemName: iconName(for: event.category))
                                                                        .foregroundColor(.white)
                                                                        .font(.caption.bold())
                                                                
                                                                Image(systemName: "triangle.fill")
                                                                        .resizable()
                                                                        .frame(width: 10, height: 8)
                                                                        .foregroundColor(backgroundColor(for: event.category))
                                                                        .offset(y: 22)
                                                                        .rotationEffect(.degrees(180))
                                                        }
                                                        .scaleEffect(selectedEvent == event ? 1.2 : 1.0)
                                                        .animation(.spring(), value: selectedEvent)
                                                }
                                                .tag(event)
                                        }
                                        
                                        UserAnnotation()
                                }
                                .mapStyle(.standard(elevation: .realistic))
                                .mapControls {
                                        MapUserLocationButton()
                                        MapCompass()
                                        MapScaleView()
                                }
                                .task {
                                        viewModel.loadEventsIfNeeded()
                                }
                                .sheet(item: $selectedEvent) { event in
                                        NavigationStack {
                                                EventPreviewSheet(event: event)
                                        }
                                        .environment(viewModel)
                                        .presentationDetents([.fraction(0.3), .medium])
                                        .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.3)))
                                }
                        }
                        .navigationTitle("Carte des Événements")
                        .navigationBarTitleDisplayMode(.inline)
                }
        }
        
        // Helpers (style)
        func iconName(for category: EventCategory) -> String {
                switch category {
                case .music: return "music.mic"
                case .sport: return "figure.run"
                case .book: return "paintpalette.fill"
                case .art: return "party.popper.fill"
                case .tech: return "bolt.fill"
                case .film: return "book.fill"
                case .food: return "gift.fill"
                case .other: return "questionmark.circle.fill"
                }
        }
        func backgroundColor(for category: EventCategory) -> Color {
                switch category {
                case .music: return .purple
                case .sport: return .orange
                case .book: return .red
                case .art: return .pink
                case .food: return .cyan
                case .tech: return .yellow
                case .film: return .green
                case .other: return .gray
                }
        }
}

// Vue partielle pour l'aperçu
struct EventPreviewSheet: View {
        let event: Event
        
        var body: some View {
                HStack(alignment: .top, spacing: 15) {
                        
                        // Image
                        if let urlString = event.imageURL, let url = URL(string: urlString) {
                                AsyncImage(url: url) { img in
                                        img.resizable().scaledToFill()
                                } placeholder: {
                                        Color.gray.opacity(0.3)
                                }
                                .frame(width: 80, height: 80)
                                .cornerRadius(12)
                                .clipped()
                        } else {
                                RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 80, height: 80)
                                        .overlay(Image(systemName: "photo").foregroundStyle(.gray))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                        .font(.headline)
                                        .lineLimit(1)
                                
                                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                
                                Text(event.location)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                
                                Spacer()
                                
                                // Le NavigationLink fonctionne maintenant car il est dans un NavigationStack (voir plus haut)
                                NavigationLink(destination: EventDetailView(event: event)) {
                                        Text("Voir détails")
                                                .font(.caption.bold())
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.blue)
                                                .foregroundStyle(.white)
                                                .cornerRadius(20)
                                }
                        }
                        Spacer()
                }
                .padding()
                // Ajout d'un titre vide pour que le NavigationStack ne prenne pas trop de place
                .toolbar(.hidden, for: .navigationBar)
                .background(Color(UIColor.secondarySystemBackground))
        }
}
