//
//  EventListViewModelTests.swift
//  EventoriasTests
//
//  Created by Perez William on 08/01/2026.
//

import Testing
import Foundation
import FirebaseCore
@testable import Eventorias

@MainActor
struct EventListViewModelTests {
        
        let viewModel: EventListViewModel
        let mockEventService: MockEventService
        let mockAuthService: MockAuthService
        
        init() {
                if FirebaseApp.app() == nil { FirebaseApp.configure() }
                
                self.mockEventService = MockEventService()
                self.mockAuthService = MockAuthService()
                
                self.viewModel = EventListViewModel(
                        eventService: mockEventService,
                        authService: mockAuthService
                )
        }
        
        // MARK: - Tests Fetch
        
        @Test("Chargement réussi")
        func fetchEventsSuccess() async {
                // Given
                let event = Event(userId: "u1", title: "Party", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                
                // When
                await viewModel.fetchEvents()
                
                // Then
                #expect(viewModel.events.count == 1)
                #expect(viewModel.isLoading == false)
                #expect(viewModel.errorMessage == nil)
        }
        
        @Test("Echec chargement (Erreur Serveur)")
        func fetchEventsFailure() async {
                // Given
                mockEventService.shouldReturnError = true
                
                // When
                await viewModel.fetchEvents()
                
                // Then
                #expect(viewModel.events.isEmpty)
                #expect(viewModel.isLoading == false)
                #expect(viewModel.errorMessage == "Erreur de chargement.")
        }
        
        @Test("LoadIfNeeded déclenche le chargement si vide")
        func loadEventsTrigger() async throws {
                // Given
                viewModel.events = []
                let event = Event(userId: "u1", title: "Loaded", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                
                // When
                viewModel.loadEventsIfNeeded()
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(viewModel.events.count == 1)
                #expect(viewModel.events.first?.title == "Loaded")
        }
        
        @Test("LoadIfNeeded ne recharge pas si déjà rempli")
        func loadIfNeededLogic() async throws {
                // Given
                let event = Event(userId: "u1", title: "Existing", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                viewModel.events = [event]
                mockEventService.shouldReturnError = true
                
                // When
                viewModel.loadEventsIfNeeded()
                try await Task.sleep(nanoseconds: 50_000_000)
                
                // Then
                #expect(viewModel.errorMessage == nil)
        }
        
        // MARK: - Tests Add
        
        @Test("Ajout réussi")
        func addEventSuccess() async throws {
                // Given
                mockAuthService.mockUserId = "me"
                
                // When
                viewModel.addEvent(title: "New", description: "Desc", date: Date(), location: "Loc", category: .art, latitude: 0, longitude: 0, newImageData: nil)
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(viewModel.events.count == 1)
                #expect(viewModel.events.first?.userId == "me")
        }
        
        @Test("Ajout d'événement AVEC Image (Test Upload)")
        func addEventWithImage() async throws {
                // Given
                mockAuthService.mockUserId = "user_123"
                let fakeImageData = Data([0x00, 0x01, 0x02])
                
                // When
                viewModel.addEvent(
                        title: "Avec Image",
                        description: "Desc",
                        date: Date(),
                        location: "Loc",
                        category: .art,
                        latitude: 0,
                        longitude: 0,
                        newImageData: fakeImageData
                )
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                let addedEvent = try #require(viewModel.events.first)
                #expect(addedEvent.imageURL == "https://mock.com/event.jpg")
        }
        
        @Test("Echec Ajout")
        func addEventFailure() async throws {
                // Given
                mockAuthService.mockUserId = "me"
                mockEventService.shouldReturnError = true
                
                // When
                viewModel.addEvent(title: "New", description: "", date: Date(), location: "", category: .art, latitude: 0, longitude: 0, newImageData: nil)
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(viewModel.events.isEmpty)
                #expect(viewModel.errorMessage == "Impossible de créer l'événement.")
        }
        
        // MARK: - Tests Delete
        
        @Test("Suppression Réussie (Execution complète)")
        func deleteEventSuccessExecution() async throws {
                // Given
                let event = Event(userId: "u1", title: "To Delete", description: "", date: Date(), location: "", category: .other, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                let targetEvent = try #require(viewModel.events.first)
                
                // When
                viewModel.deleteEvent(targetEvent)
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(viewModel.events.isEmpty)
                #expect(viewModel.errorMessage == nil)
        }
        
        @Test("Suppression avec Rollback (Optimistic UI)")
        func deleteEventRollback() async throws {
                // Given
                let event = Event(userId: "u1", title: "To Delete", description: "", date: Date(), location: "", category: .other, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                mockEventService.shouldReturnError = true
                
                // When
                viewModel.deleteEvent(event)
                
                // Then 1 (Optimistic)
                #expect(viewModel.events.isEmpty)
                
                // When 2 (Rollback)
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then 2
                #expect(viewModel.events.count == 1)
                #expect(viewModel.events.first?.title == "To Delete")
        }
        
        @Test("Rollback Suppression avec modification concurrente (Branche Append)")
        func deleteEventRollbackWithConcurrentChange() async throws {
                // Given
                let event1 = Event(userId: "u1", title: "Keep Me", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                let event2 = Event(userId: "u1", title: "Delete Me", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event1, event2]
                await viewModel.fetchEvents()
                let eventToDelete = event2
                
                // When
                mockEventService.shouldReturnError = true
                viewModel.deleteEvent(eventToDelete)
                
                // Sabotage concurrent
                viewModel.events = []
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(viewModel.events.count == 1)
                #expect(viewModel.events.first?.title == "Delete Me")
        }
        
        // MARK: Tests Participation
        
        @Test("Rejoindre un événement (Toggle Join)")
        func joinEvent() async throws {
                // Given
                let myId = "my_id"
                mockAuthService.mockUserId = myId
                let event = Event(userId: "other", title: "Party", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                let eventToJoin = try #require(viewModel.events.first)
                
                // When
                viewModel.toggleParticipation(event: eventToJoin)
                
                // Then (Optimistic)
                #expect(viewModel.events.first?.attendees.contains(myId) == true)
                
                // Then (Service)
                try await Task.sleep(nanoseconds: 200_000_000)
                #expect(mockEventService.mockEvents.first?.attendees.contains(myId) == true)
        }
        
        @Test("Quitter un événement (Toggle Leave)")
        func leaveEvent() async throws {
                // Given
                let myId = "my_id"
                mockAuthService.mockUserId = myId
                let event = Event(userId: "other", title: "Party", description: "", date: Date(), location: "", category: .music, attendees: [myId], imageURL: nil, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                let eventToLeave = try #require(viewModel.events.first)
                
                // When
                viewModel.toggleParticipation(event: eventToLeave)
                
                // Then
                #expect(viewModel.events.first?.attendees.contains(myId) == false)
                try await Task.sleep(nanoseconds: 200_000_000)
                #expect(mockEventService.mockEvents.first?.attendees.contains(myId) == false)
        }
        
        @Test("Echec Participation")
        func toggleParticipationFailure() async throws {
                // Given
                mockAuthService.mockUserId = "user_123"
                let event = Event(userId: "host", title: "Party", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                let targetEvent = try #require(viewModel.events.first)
                mockEventService.shouldReturnError = true
                
                // When
                viewModel.toggleParticipation(event: targetEvent)
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(viewModel.errorMessage == "Erreur de chargement.")
        }
        
        // MARK: - Tests Édition
        
        @Test("Modification avec mise à jour des notifications (Branche Notification)")
        func editEventWithNotificationUpdate() async throws {
                // Given
                let myId = "user_vip"
                mockAuthService.mockUserId = myId
                let event = Event(userId: "host", title: "Avant", description: "Old", date: Date(), location: "Paris", category: .music, attendees: [myId], imageURL: nil, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                let eventToEdit = try #require(viewModel.events.first)
                
                // When
                viewModel.editEvent(
                        event: eventToEdit,
                        title: "Après Notification",
                        description: "New Desc",
                        date: Date().addingTimeInterval(3600),
                        location: "Lyon",
                        category: .music,
                        newImageData: nil
                )
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                let updatedEvent = try #require(viewModel.events.first)
                #expect(updatedEvent.title == "Après Notification")
        }
        
        @Test("Echec Modification (Branche Catch)")
        func editEventFailure() async throws {
                // Given
                let event = Event(userId: "u1", title: "Avant", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                let eventToEdit = try #require(viewModel.events.first)
                mockEventService.shouldReturnError = true
                
                // When
                viewModel.editEvent(
                        event: eventToEdit,
                        title: "Crash",
                        description: "",
                        date: Date(),
                        location: "",
                        category: .music,
                        newImageData: nil
                )
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(viewModel.isLoading == false)
        }
        
        @Test("Echec Édition : Vérification du message d'erreur")
        func editEventFailureCheck() async throws {
                // Given
                let event = Event(userId: "u1", title: "Original", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                let eventToEdit = try #require(viewModel.events.first)
                mockEventService.shouldReturnError = true
                
                // When
                viewModel.editEvent(
                        event: eventToEdit,
                        title: "Titre Modifié",
                        description: "Desc",
                        date: Date(),
                        location: "Loc",
                        category: .music,
                        newImageData: nil
                )
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(viewModel.errorMessage == "Impossible de modifier l'événement.")
                #expect(viewModel.isLoading == false)
        }
        
        // MARK: Tests Gards
        
        @Test("Tentative d'action sans être connecté (Guard Check)")
        func actionWithoutUser() async throws {
                // Given
                mockAuthService.mockUserId = nil
                
                // When
                viewModel.addEvent(title: "Fantôme", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0, newImageData: nil)
                try await Task.sleep(nanoseconds: 50_000_000)
                
                // Then
                #expect(viewModel.isLoading == false)
                #expect(viewModel.events.isEmpty)
        }
        
        @Test("Action sur un événement introuvable (Guard Index)")
        func actionOnUnknownEvent() async {
                // Given
                mockEventService.mockEvents = []
                await viewModel.fetchEvents()
                let ghostEvent = Event(userId: "u1", title: "Ghost", description: "", date: Date(), location: "", category: .other, latitude: 0, longitude: 0)
                
                // When (Delete)
                viewModel.deleteEvent(ghostEvent)
                
                // When (Join)
                mockAuthService.mockUserId = "u1"
                viewModel.toggleParticipation(event: ghostEvent)
                
                // Then
                #expect(viewModel.isLoading == false)
                #expect(viewModel.events.isEmpty)
        }
}
