//
//  EventListViewModel.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation
import Observation
import FirebaseAuth

@Observable
class EventListViewModel {
        
        //MARK: properties
        var events: [Event] = []
        
        private let service: Service
        
        //MARK: init
        init(service: Service = Service()) {
                self.service = service
                fetchEvents()
        }
        
        // MARK: lecture
        func fetchEvents() {
                service.listenToEvents { [weak self] fetchedEvents in
                        self?.events = fetchedEvents
                }
        }
        
        // MARK: ajout
        func addEvent(title: String, description: String, date: Date, location: String, category: EventCategory, userId: String) {
                let newEvent = Event(
                        userId: userId,
                        title: title,
                        description: description,
                        date: date,
                        location: location,
                        category: category
                )
               
                service.add(newEvent)
        }
        
        // MARK: suppression
        func deleteEvent(at offsets: IndexSet) {
                guard let currentUserId = Auth.auth().currentUser?.uid else { return }
                
                offsets.forEach { index in
                        let event = events[index]
                        
                        /// seul le propriétaire peut supprimer
                        if event.userId == currentUserId, let eventId = event.id {
                                service.delete(eventId: eventId)
                        }
                }
        }
        
        // MARK: participation
        func toggleParticipation(event: Event) {
                guard let eventId = event.id,
                      let currentUserId = Auth.auth().currentUser?.uid else { return }
                
                // on rejoint ou on quitte ?
                let isJoining = !event.attendees.contains(currentUserId)
                
                service.updateParticipation(eventId: eventId, userId: currentUserId, isJoining: isJoining)
        }
}
