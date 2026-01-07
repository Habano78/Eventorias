//
//  MockEventService.swift
//  EventoriasTests
//
//  Created by Perez William on 16/12/2025.
//

import Foundation
@testable import Eventorias


final class MockEventService: EventServiceProtocol, @unchecked Sendable {
        
        // Fausse base de données
        var mockEvents: [Event] = []
        var mockUser: User?
        var mockUserId: String? = "test_user_id"
        var mockSessionId: String? = "test_session_id"
        var shouldReturnError = false
        
        
        // MARK: Implementation du Protocol
        
        var currentUserId: String? {
                return mockUserId
        }
        
        func fetchEvents() async throws -> [Event] {
                if shouldReturnError { throw NSError(domain: "Test", code: 1) }
                return mockEvents
        }
        
        func addEvent(_ event: Event) async throws {
                if shouldReturnError { throw NSError(domain: "Test", code: 1) }
                mockEvents.append(event)
        }
        
        func deleteEvent(eventId: String) async throws {
                mockEvents.removeAll { $0.id == eventId }
        }
        
        func updateEvent(_ event: Event) async throws {
                if let index = mockEvents.firstIndex(where: { $0.id == event.id }) {
                        mockEvents[index] = event
                }
        }
        
        func editEvent(event: Event, title: String, description: String, date: Date, location: String, category: EventCategory, newImageData: Data?) async throws {
                
                if let index = mockEvents.firstIndex(where: { $0.id == event.id }) {
                        
                        let updated = mockEvents[index]
                        updated.title = title
                        updated.description = description
                        updated.date = date
                        updated.location = location
                        updated.category = category
                        
                        mockEvents[index] = updated
                }
        }
        
        func updateParticipation(eventId: String, userId: String, isJoining: Bool) async throws {
                if let index = mockEvents.firstIndex(where: { $0.id == eventId }) {
                        let event = mockEvents[index]
                        if isJoining {
                                event.attendees.append(userId)
                        } else {
                                event.attendees.removeAll { $0 == userId }
                        }
                        mockEvents[index] = event
                }
        }
        
        func uploadImage(data: Data) async throws -> String {
                return "https://mock-url.com/image.jpg"
        }
        
        
        // MARK:  User
        func saveUser(_ user: User) async throws {
                self.mockUser = user
        }
        
        func fetchUser(userId: String) async throws -> User? {
                if shouldReturnError { throw NSError(domain: "Test", code: 2) }
                return mockUser
        }
        
        //MARK: Auth
        func signIn(email: String, password: String) async throws -> String {
                if shouldReturnError { throw NSError(domain: "Auth", code: 401) }
                // On fait semblant que ça a marché
                return mockUserId ?? "test_user_id"
            }
            
            func signUp(email: String, password: String) async throws -> String {
                if shouldReturnError { throw NSError(domain: "Auth", code: 500) }
                return "new_user_id_created"
            }
            
            func signOut() throws {
            }
}
