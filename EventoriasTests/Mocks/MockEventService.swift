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
        
        nonisolated(unsafe) var mockEvents: [Event] = []
        nonisolated(unsafe) var shouldReturnError = false
        
        func fetchEvents() async throws -> [Event] {
                if shouldReturnError { throw NSError(domain: "Event", code: 500) }
                return mockEvents
        }
        
        func addEvent(_ event: Event) async throws {
                if shouldReturnError { throw NSError(domain: "Event", code: 500) }
                mockEvents.append(event)
        }
        
        func deleteEvent(eventId: String) async throws {
                if shouldReturnError { throw NSError(domain: "Event", code: 500) }
                mockEvents.removeAll { $0.id == eventId }
        }
        
        func editEvent(event: Event, title: String, description: String, date: Date, location: String, category: EventCategory, newImageData: Data?) async throws {
                
                if shouldReturnError { throw NSError(domain: "Event", code: 500) }
                
                if let index = mockEvents.firstIndex(where: { $0.id == event.id }) {
                        let newEvent = Event(
                                id: event.id,
                                userId: event.userId,
                                title: title,
                                description: description,
                                date: date,
                                location: location,
                                category: category,
                                attendees: event.attendees,
                                imageURL: newImageData != nil ? "new_url" : event.imageURL,
                                latitude: event.latitude,
                                longitude: event.longitude
                        )
                        mockEvents[index] = newEvent
                }
        }
        
        func updateParticipation(eventId: String, userId: String, isJoining: Bool) async throws {
                
                if shouldReturnError { throw NSError(domain: "Event", code: 500) }
                
                if let index = mockEvents.firstIndex(where: { $0.id == eventId }) {
                        let oldEvent = mockEvents[index]
                        var newAttendees = oldEvent.attendees
                        
                        if isJoining {
                                newAttendees.append(userId)
                        } else {
                                newAttendees.removeAll { $0 == userId }
                        }
                        
                        let updated = Event(
                                id: oldEvent.id,
                                userId: oldEvent.userId,
                                title: oldEvent.title,
                                description: oldEvent.description,
                                date: oldEvent.date,
                                location: oldEvent.location,
                                category: oldEvent.category,
                                attendees: newAttendees,
                                imageURL: oldEvent.imageURL,
                                latitude: oldEvent.latitude,
                                longitude: oldEvent.longitude
                        )
                        mockEvents[index] = updated
                }
        }
        
        func uploadEventImage(data: Data) async throws -> String {
                if shouldReturnError { throw NSError(domain: "Event", code: 500) }
                return "https://mock.com/event.jpg"
        }
}
