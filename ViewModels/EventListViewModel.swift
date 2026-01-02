//
//  EventListViewModel.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation
import Observation
import MapKit
import SwiftUI

@MainActor
@Observable
class EventListViewModel {
        
        //MARK: Inst
        private let service = Service.shared
        
        // MARK: Properties
        var events: [Event] = []
        var isLoading: Bool = false
        var errorMessage: String?
        var selectedCategory: EventCategory? = nil
        
        // donner accès à l'ID sans exposer tout le service
        var currentUserId: String? {
            return service.currentUserId
        }
        
        
        // MARK: Init
        init() { }
        
        // MARK: Methods
        func loadEventsIfNeeded() {
                guard events.isEmpty else { return }
                
                Task {
                        await fetchEvents()
                }
        }
        
        func fetchEvents() async {
                isLoading = true
                errorMessage = nil
                
                do {
                        self.events = try await service.fetchEvents()
                } catch {
                        self.errorMessage = "Erreur chargement : \(error.localizedDescription)"
                        print("Erreur Fetch: \(error)")
                }
                
                isLoading = false
        }
        
        func deleteEvent(withId eventId: String) {
                if let index = events.firstIndex(where: { $0.id == eventId }) {
                        events.remove(at: index)
                }
                
                Task {
                        do {
                                try await service.deleteEvent(eventId: eventId)
                                print("Événement supprimé de Firestore")
                        } catch {
                                print("Erreur suppression : \(error)")
                                
                                await fetchEvents()
                        }
                }
        }
        
        // MARK: Participation
        
        func toggleParticipation(event: Event) {
                guard let currentUserId = service.currentUserId else { return }
                guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
                
                let liveEvent = events[index]
                
                let isJoining = !liveEvent.attendees.contains(currentUserId)
                
                
                var updatedAttendees = liveEvent.attendees
                if isJoining {
                        updatedAttendees.append(currentUserId)
                } else {
                        updatedAttendees.removeAll { $0 == currentUserId }
                }
                
                events[index].attendees = updatedAttendees
                
                Task {
                        do {
                                try await service.updateParticipation(eventId: liveEvent.id, userId: currentUserId, isJoining: isJoining)
                        } catch {
                                print("Erreur participation: \(error)")
                                await fetchEvents()
                        }
                }
        }
        
        //MARK: AddEvent
        func addEvent(title: String, description: String, date: Date, locationName: String, category: EventCategory, imageData: Data?) {
                
                guard let userId = service.currentUserId else {
                        print("Erreur : Aucun utilisateur connecté.")
                        return
                }
                
                self.isLoading = true
                self.errorMessage = nil
                
                Task {
                        
                        var finalCoordinates = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
                        
                        
                        do {
                                finalCoordinates = try await getCoordinates(from: locationName)
                        } catch {
                                print("⚠️ Warning GPS : \(error.localizedDescription). Utilisation des coordonnées par défaut.")
                        }
                        
                        do {
                                var imageURL: String? = nil
                                if let data = imageData {
                                        imageURL = try await service.uploadImage(data: data)
                                }
                                
                                let newEvent = Event(
                                        userId: userId,
                                        title: title,
                                        description: description,
                                        date: date,
                                        location: locationName,
                                        category: category,
                                        attendees: [],
                                        imageURL: imageURL,
                                        latitude: finalCoordinates.latitude,
                                        longitude: finalCoordinates.longitude
                                )
                                
                                try await service.addEvent(newEvent)
                                
                                await fetchEvents()
                                
                                print("SUCCÈS : Événement ajouté dans Firestore !")
                                
                        } catch {
                                print("ERREUR SAUVEGARDE : \(error)")
                                self.errorMessage = "Impossible de créer l'événement : \(error.localizedDescription)"
                        }
                        
                        self.isLoading = false
                }
        }
        
        //MARK: Modifier
        func updateEvent(event: Event, title: String, description: String, date: Date, location: String, category: EventCategory, newImageData: Data?) {
                
                self.isLoading = true
                
                Task {
                        do {
                                try await service.updateEvent(
                                        event: event,
                                        title: title,
                                        description: description,
                                        date: date,
                                        location: location,
                                        category: category,
                                        newImageData: newImageData
                                )
                                
                                await fetchEvents()
                                print("✅ Événement mis à jour avec succès !")
                                
                        } catch {
                                print("Erreur modification : \(error.localizedDescription)")
                                self.errorMessage = "Impossible de modifier l'événement."
                        }
                        
                        self.isLoading = false
                }
        }
        
        //MARK:  Helper
        private func getCoordinates(from locationName: String) async throws -> CLLocationCoordinate2D {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = locationName
                let search = MKLocalSearch(request: request)
                
                let response = try await search.start()
                
                if let item = response.mapItems.first {
                        return item.location.coordinate
                } else {
                        
                        return CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
                }
        }
}
