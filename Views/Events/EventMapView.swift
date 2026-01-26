//
//  EventMapView.swift
//  Eventorias
//
//  Created by Perez William on 28/12/2025.
//

import SwiftUI
import MapKit

struct EventMapView: View {
        
        //MARK: dependence
        @Environment(EventListViewModel.self) var eventListViewModel
        
        @State private var position: MapCameraPosition = .automatic
        @State private var selectedEvent: Event?
        
        //MARK: Body
        var body: some View {
                NavigationStack {
                        Map(position: $position, interactionModes: .all, selection: $selectedEvent) {
                                ForEach(eventListViewModel.events) { event in
                                        Annotation(event.title, coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude)) {
                                                ZStack {
                                                        RoundedRectangle(cornerRadius: 8)
                                                                .fill(event.category.color)
                                                                .frame(width: 35, height: 35)
                                                                .shadow(radius: 3)
                                                        
                                                        Image(systemName: event.category.iconName)
                                                                .foregroundColor(.white)
                                                                .font(.caption.bold())
                                                        
                                                        Image(systemName: "triangle.fill")
                                                                .resizable()
                                                                .frame(width: 10, height: 8)
                                                                .foregroundColor(event.category.color)
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
                                await eventListViewModel.loadEventsIfNeeded()
                        }
                        .sheet(item: $selectedEvent) { event in
                                NavigationStack {
                                        EventPreviewSheet(event: event)
                                }
                                .environment(eventListViewModel)
                                .presentationDetents([.fraction(0.3), .medium])
                                .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.3)))
                        }
                }
                .navigationTitle("Carte des Événements")
                .navigationBarTitleDisplayMode(.inline)
        }
        
}

//MARK: Vue partielle pour l'aperçu
private struct EventPreviewSheet: View {
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
                .toolbar(.hidden, for: .navigationBar)
                .background(Color(UIColor.secondarySystemBackground))
        }
}
