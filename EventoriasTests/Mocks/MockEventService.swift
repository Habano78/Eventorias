//
//  MockEventService.swift
//  EventoriasTests
//
//  Created by Perez William on 08/01/2026.
//

import Foundation
@testable import Eventorias

@MainActor
final class MockEventService: EventServiceProtocol {
        
        // MARK: State
        var mockEvents: [Event] = []
        var shouldReturnError = false
        
        // MARK: Hooks
        var onFetchEvents: (() -> Void)?
        var onAddEvent: (() -> Void)?
        var onDeleteEvent: (() -> Void)?
        var onEditEvent: (() -> Void)?
        var onUpdateParticipation: (() -> Void)?
        var onUploadImage: (() -> Void)?
        
        // MARK: Implementation
        
        func fetchEvents() async throws -> [Event] {
                defer { onFetchEvents?() }
                
                if shouldReturnError {
                        throw NSError(domain: "Mock", code: 500, userInfo: [NSLocalizedDescriptionKey: "Erreur serveur simulée"])
                }
                return mockEvents
        }
        
        func addEvent(_ event: Event) async throws {
                defer { onAddEvent?() }
                
                if shouldReturnError {
                        throw NSError(domain: "Mock", code: 500)
                }
                mockEvents.append(event)
        }
        
        func deleteEvent(eventId: String) async throws {
                defer { onDeleteEvent?() }
                
                if shouldReturnError {
                        throw NSError(domain: "Mock", code: 500)
                }
                mockEvents.removeAll { $0.id == eventId }
        }
        
        func editEvent(event: Event,
                       title: String,
                       description: String,
                       date: Date,
                       location: String,
                       category: EventCategory,
                       newImageData: Data?) async throws {
                
                defer { onEditEvent?() }
                
                if shouldReturnError {
                        throw NSError(domain: "Mock", code: 500)
                }
                
                guard let index = mockEvents.firstIndex(where: { $0.id == event.id }) else {
                        return
                }
                
                // Simulation image
                let finalImageURL = newImageData != nil ? "https://mock.com/updated_image.jpg" : event.imageURL
                
                //Création d'une nouvelle instance
                let updatedEvent = Event(
                        id: event.id,
                        userId: event.userId,
                        title: title,
                        description: description,
                        date: date,
                        location: location,
                        category: category,
                        attendees: event.attendees,
                        imageURL: finalImageURL,
                        latitude: event.latitude,
                        longitude: event.longitude
                )
                
                mockEvents[index] = updatedEvent
        }
        
        func updateParticipation(eventId: String, userId: String, isJoining: Bool) async throws {
                defer { onUpdateParticipation?() }
                
                if shouldReturnError {
                        throw NSError(domain: "Mock", code: 500)
                }
                
                guard let index = mockEvents.firstIndex(where: { $0.id == eventId }) else {
                        return
                }
                
                var eventToUpdate = mockEvents[index]
                
                if isJoining {
                        if !eventToUpdate.attendees.contains(userId) {
                                eventToUpdate.attendees.append(userId)
                        }
                } else {
                        eventToUpdate.attendees.removeAll { $0 == userId }
                }
                
                mockEvents[index] = eventToUpdate
        }
        
        func uploadEventImage(data: Data) async throws -> String {
                defer { onUploadImage?() }
                if shouldReturnError { throw NSError(domain: "Event", code: 500) }
                return "https://mock.com/event.jpg"
        }
}
