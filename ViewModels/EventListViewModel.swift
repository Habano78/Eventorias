//
//  EventListViewModel.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation
import Observation
import MapKit

@Observable
class EventListViewModel {
        
        // MARK: Properties
        var events: [Event] = []
        var isLoading: Bool = false
        var errorMessage: String?
        
        private let service = Service()
        
        
        // MARK: init
        init() {
                fetchEvents()
        }
        
        // MARK: Methods
        
        func fetchEvents() {
                self.isLoading = true
                service.fetchEvents { [weak self] fetchedEvents in
                        self?.events = fetchedEvents
                        self?.isLoading = false
                }
        }
        
        func deleteEvent(indexSet: IndexSet) {
                for index in indexSet {
                        let event = events[index]
                        
                        events.remove(at: index)
                        
                        if let eventId = event.id {
                                service.deleteEvent(eventId: eventId) { success in
                                        if !success {
                                                print("Erreur suppression")
                                                
                                                self.fetchEvents()
                                        }
                                }
                        }
                }
        }
        
        //MARK: participation
        func toggleParticipation(event: Event) {
                guard let currentUserId = service.currentUserId, let eventId = event.id else { return }
                
                var updatedEvent = event
                
                if event.attendees.contains(currentUserId) {
                        updatedEvent.attendees.removeAll { $0 == currentUserId }
                } else {
                        updatedEvent.attendees.append(currentUserId)
                }
                
                if let index = events.firstIndex(where: { $0.id == event.id }) {
                        events[index] = updatedEvent
                }
                
                service.updateEvent(event: updatedEvent) { success in
                        if !success {
                                self.fetchEvents()
                        }
                }
        }
        
        // MARK: ajout d'EVENT
        func addEvent(title: String, description: String, date: Date, location: String, category: EventCategory, userId: String, imageData: Data?) {
                
                self.isLoading = true
                
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = location
                
                let search = MKLocalSearch(request: request)
                
                search.start { [weak self] response, error in
                        
                        var lat = 48.8566
                        var long = 2.3522
                        
                        if let mapItem = response?.mapItems.first, let location = mapItem.placemark.location {
                                lat = location.coordinate.latitude
                                long = location.coordinate.longitude
                        } else {
                                print("Aucun lieu trouvé")
                        }
                        
                        let saveToFirestore = { (url: String?) in
                                
                                let newEvent = Event(
                                        id: nil,
                                        userId: userId,
                                        title: title,
                                        description: description,
                                        date: date,
                                        location: location,
                                        category: category,
                                        attendees: [],
                                        imageURL: url,
                                        latitude: lat,
                                        longitude: long
                                )
                                
                                self?.service.addEvent(event: newEvent) { success in
                                        if success {
                                                self?.fetchEvents()
                                        }
                                        self?.isLoading = false
                                }
                        }
                        
                        /// Gestion image
                        if let imageData = imageData {
                                self?.service.uploadImage(data: imageData) { url in
                                        saveToFirestore(url)
                                }
                        } else {
                                saveToFirestore(nil)
                        }
                }
        }
}
