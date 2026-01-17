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
        
        // MARK: Properties
        let viewModel: EventListViewModel
        let mockEventService: MockEventService
        let mockAuthService: MockAuthService
        
        // MARK: Setup
        init() {
                if FirebaseApp.app() == nil { FirebaseApp.configure() }
                
                self.mockEventService = MockEventService()
                self.mockAuthService = MockAuthService()
                
                self.viewModel = EventListViewModel(
                        eventService: mockEventService,
                        authService: mockAuthService
                )
        }
        
        // MARK: Fetch
        
        @Test("FetchEvents: Charge les événements avec succès")
        func fetchEventsSuccess() async {
                // Given
                let event = Event(userId: "u1", title: "Party", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                
                // When
                await confirmation { confirm in
                        mockEventService.onFetchEvents = { confirm() }
                        await viewModel.fetchEvents()
                }
                
                // Then
                #expect(viewModel.events.count == 1)
                #expect(viewModel.isLoading == false)
        }
        
        @Test("FetchEvents: Gère une erreur de service")
        func fetchEventsFailure() async {
                // Given
                mockEventService.shouldReturnError = true
                
                // When
                await confirmation { confirm in
                        mockEventService.onFetchEvents = { confirm() }
                        await viewModel.fetchEvents()
                }
                
                // Then
                #expect(viewModel.events.isEmpty)
                #expect(viewModel.errorMessage != nil)
        }
        
        @Test("LoadEventsIfNeeded: Déclenche un fetch quand la liste est vide")
        func loadEventsTrigger() async {
                // Given
                let event = Event(userId: "u1", title: "Loaded", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                
                // When
                await confirmation { confirm in
                        mockEventService.onFetchEvents = { confirm() }
                        await viewModel.loadEventsIfNeeded()
                }
                
                // Then
                #expect(viewModel.events.count == 1)
        }
        
        @Test("LoadEventsIfNeeded: Ne fait rien si les événements sont déjà chargés")
        func loadEventsIfNeeded_doesNothingIfAlreadyLoaded() async {
                // Given
                viewModel.events = [Event(userId: "u1", title: "Already", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)]
                var fetchCalled = false
                mockEventService.onFetchEvents = { fetchCalled = true }
                
                // When
                await viewModel.loadEventsIfNeeded()
                
                // Then
                #expect(fetchCalled == false)
        }
        
        // MARK: Add
        
        @Test("AddEvent: Ajoute un événement avec image")
        func addEventWithImage() async throws {
                // Given
                mockAuthService.mockUserId = "user_123"
                let imageData = Data([0x00])
                
                // When
                await confirmation { confirm in
                        mockEventService.onAddEvent = { confirm() }
                        await viewModel.addEvent(title: "Avec Image", description: "", date: Date(), location: "", category: .art, latitude: 0, longitude: 0, newImageData: imageData)
                }
                
                // Then
                let event = try #require(viewModel.events.first)
                #expect(event.imageURL == "https://mock.com/event.jpg")
        }
        
        @Test("AddEvent: Crée un événement sans URL si pas d'image")
        func addEvent_withoutImage() async throws {
                // Given
                mockAuthService.mockUserId = "u1"
                
                // When
                await confirmation { confirm in
                        mockEventService.onAddEvent = { confirm() }
                        await viewModel.addEvent(title: "Sans image", description: "", date: .now, location: "", category: .art, latitude: 0, longitude: 0, newImageData: nil)
                }
                
                // Then
                let event = try #require(viewModel.events.first)
                #expect(event.imageURL == nil)
        }
        
        @Test("AddEvent: Gère l'erreur")
        func addEventFailure() async {
                // Given
                mockAuthService.mockUserId = "u1"
                mockEventService.shouldReturnError = true
                
                // When
                await confirmation { confirm in
                        mockEventService.onAddEvent = { confirm() }
                        await viewModel.addEvent(title: "Fail", description: "", date: .now, location: "", category: .art, latitude: 0, longitude: 0, newImageData: nil)
                }
                
                // Then
                #expect(viewModel.events.isEmpty)
                #expect(viewModel.errorMessage == "Impossible de créer l'événement.")
        }
        
        @Test("AddEvent: Ne fait rien si l'utilisateur n'est pas connecté")
        func addEvent_doesNothingWhenNotLoggedIn() async {
                // Given
                mockAuthService.mockUserId = nil
                
                // When
                await viewModel.addEvent(title: "X", description: "", date: .now, location: "", category: .art, latitude: 0, longitude: 0, newImageData: nil)
                
                // Then
                #expect(viewModel.events.isEmpty)
        }
        
        @Test("ScheduleNotification: Planifie une notif pour un événement futur")
        func scheduleNotification_futureEvent() async throws {
                // Given
                mockAuthService.mockUserId = "u1"
                let futureDate = Date().addingTimeInterval(7200)
                
                // When
                await confirmation { confirm in
                        mockEventService.onAddEvent = { confirm() }
                        
                        await viewModel.addEvent(
                                title: "Futur",
                                description: "",
                                date: futureDate,
                                location: "",
                                category: .music,
                                latitude: 0,
                                longitude: 0,
                                newImageData: nil
                        )
                }
        }
        
        // MARK: Delete
        
        @Test("DeleteEvent: Supprime un événement avec succès")
        func deleteEventSuccess() async throws {
                // Given
                let event = Event(userId: "u1", title: "Delete", description: "", date: Date(), location: "", category: .other, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                
                // When
                await confirmation { confirm in
                        mockEventService.onDeleteEvent = { confirm() }
                        await viewModel.deleteEvent(event)
                }
                
                // Then
                #expect(viewModel.events.isEmpty)
        }
        
        @Test("DeleteEvent: Restaure l'événement en cas d'échec (Rollback)")
        func deleteEventRollback() async {
                // Given
                let event = Event(userId: "u1", title: "Rollback", description: "", date: Date(), location: "", category: .other, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                mockEventService.shouldReturnError = true
                
                // When
                await confirmation { confirm in
                        mockEventService.onDeleteEvent = { confirm() }
                        await viewModel.deleteEvent(event)
                }
                
                // Then
                #expect(viewModel.events.count == 1)
                #expect(viewModel.errorMessage == "Impossible de supprimer l'événement.")
        }
        
        @Test("DeleteEvent: Rollback avec append si l'index est hors limites")
        func deleteEvent_rollback_appends_ifIndexOutOfBounds() async {
                // Given
                let event1 = Event(userId: "u1", title: "Keep", description: "", date: .now, location: "", category: .music, latitude: 0, longitude: 0)
                let event2 = Event(userId: "u1", title: "Delete", description: "", date: .now, location: "", category: .music, latitude: 0, longitude: 0)
                
                mockEventService.mockEvents = [event1, event2]
                await viewModel.fetchEvents()
                
                let eventToDelete = event2
                mockEventService.shouldReturnError = true
                
                // When
                await confirmation { confirm in
                        
                        mockEventService.onDeleteEvent = {
                                self.viewModel.events = []
                                confirm()
                        }
                        
                        await viewModel.deleteEvent(eventToDelete)
                }
                
                // Then
                #expect(viewModel.events.count == 1)
                #expect(viewModel.events.first?.id == event2.id)
        }
        
        // MARK: Edit
        
        @Test("EditEvent: Modifie un événement avec succès")
        func editEventSuccess() async throws {
                // Given
                let event = Event(userId: "u1", title: "Avant", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                
                let eventToEdit = try #require(viewModel.events.first)
                
                // When
                await confirmation { confirm in
                        mockEventService.onEditEvent = { confirm() }
                        await viewModel.editEvent(event: eventToEdit, title: "Après", description: "New", date: Date(), location: "NewLoc", category: .music, newImageData: nil)
                }
                
                // Then
                let updatedEvent = try #require(viewModel.events.first)
                #expect(updatedEvent.title == "Après")
        }
        
        @Test("EditEvent: Gère l'erreur")
        func editEventFailure() async throws {
                // Given
                let event = Event(userId: "u1", title: "Avant", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                
                mockEventService.shouldReturnError = true
                let eventToEdit = try #require(viewModel.events.first)
                
                // When
                await confirmation { confirm in
                        mockEventService.onEditEvent = { confirm() }
                        await viewModel.editEvent(event: eventToEdit, title: "Crash", description: "", date: Date(), location: "", category: .music, newImageData: nil)
                }
                
                // Then
                #expect(viewModel.errorMessage == "Impossible de modifier l'événement.")
        }
        
        @Test("EditEvent: Met à jour la notification si l'utilisateur participe")
        func editEvent_updatesNotification_ifParticipating() async throws {
                // Given
                mockAuthService.mockUserId = "u1"
                
                let event = Event(
                        userId: "host",
                        title: "Avant",
                        description: "",
                        date: Date(),
                        location: "Paris",
                        category: .music,
                        attendees: ["u1"],
                        latitude: 0,
                        longitude: 0
                )
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                
                let eventToEdit = try #require(viewModel.events.first)
                
                // When
                await confirmation { confirm in
                        mockEventService.onEditEvent = { confirm() }
                        
                        await viewModel.editEvent(
                                event: eventToEdit,
                                title: "Après",
                                description: "New",
                                date: Date().addingTimeInterval(3600),
                                location: "Lyon",
                                category: .music,
                                newImageData: nil
                        )
                }
        }
        
        // MARK: Participation (Toggle)
        
        @Test("ToggleParticipation: Rejoint un événement")
        func toggleParticipation_joinEvent() async {
                // Given
                mockAuthService.mockUserId = "me"
                let event = Event(userId: "host", title: "Party", description: "", date: .now, location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                
                // When
                await confirmation { confirm in
                        mockEventService.onUpdateParticipation = { confirm() }
                        await viewModel.toggleParticipation(event: event)
                }
                
                // Then
                #expect(viewModel.events.first?.attendees.contains("me") == true)
        }
        
        @Test("ToggleParticipation: Retire l'utilisateur d'un événement")
        func toggleParticipation_leaveEvent() async {
                // Given
                mockAuthService.mockUserId = "u1"
                let event = Event(userId: "host", title: "Party", description: "", date: .now, location: "", category: .music, attendees: ["u1"], latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                
                // When
                await confirmation { confirm in
                        mockEventService.onUpdateParticipation = { confirm() }
                        await viewModel.toggleParticipation(event: event)
                }
                
                // Then
                #expect(viewModel.events.first?.attendees.isEmpty == true)
        }
        
        @Test("ToggleParticipation: Gère l'erreur (Rollback)")
        func toggleParticipationFailure() async {
                // Given
                mockAuthService.mockUserId = "me"
                
                let event = Event(userId: "host", title: "Party", description: "", date: .now, location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                
                mockEventService.shouldReturnError = true
                
                // When
                await viewModel.toggleParticipation(event: event)
                
                // Then
                #expect(viewModel.errorMessage == "Impossible de modifier la participation.")
                let eventInList = viewModel.events.first
                #expect(eventInList?.attendees.contains("me") == false)
        }
        
        @Test("ToggleParticipation: Ne fait rien sans utilisateur")
        func toggleParticipation_noUser_doesNothing() async {
                // Given
                mockAuthService.mockUserId = nil
                let event = Event(userId: "u1", title: "Test", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                
                // When
                await viewModel.toggleParticipation(event: event)
                
                // Then
                #expect(viewModel.events.isEmpty)
        }
        
        // MARK: Clear Data
        
        @Test("ClearData: Réinitialise toutes les propriétés du ViewModel")
        func clearData_resetsEverything() async {
                // Given
                // On "salit" le ViewModel avec des données
                let event = Event(userId: "u1", title: "Test", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                viewModel.events = [event]
                viewModel.selectedCategory = .music
                viewModel.errorMessage = "Une erreur persistante"
                viewModel.isLoading = true
                
                // When
                viewModel.clearData()
                
                // Then
                #expect(viewModel.events.isEmpty)
                #expect(viewModel.selectedCategory == nil)
                #expect(viewModel.errorMessage == nil)
                #expect(viewModel.isLoading == false)
        }
        
        // MARK: isOwner
        
        @Test("IsOwner: Renvoie VRAI si l'utilisateur est le créateur")
        func isOwner_returnsTrue_whenMatching() {
                // Given
                let myId = "my_user_id"
                mockAuthService.mockUserId = myId
                
                let myEvent = Event(userId: myId, title: "Mon Event", description: "", date: .now, location: "", category: .other, latitude: 0, longitude: 0)
                
                // When & Then
                #expect(viewModel.isOwner(of: myEvent) == true)
        }
        
        @Test("IsOwner: Renvoie FAUX si l'utilisateur n'est pas le créateur")
        func isOwner_returnsFalse_whenNotMatching() {
                // Given
                mockAuthService.mockUserId = "my_user_id"
                
                let otherEvent = Event(userId: "other_user_id", title: "Pas mon Event", description: "", date: .now, location: "", category: .other, latitude: 0, longitude: 0)
                
                // When & Then
                #expect(viewModel.isOwner(of: otherEvent) == false)
        }
        
        @Test("IsOwner: Renvoie FAUX si aucun utilisateur n'est connecté")
        func isOwner_returnsFalse_whenLoggedOut() {
                // Given
                mockAuthService.mockUserId = nil // Pas de session
                
                let someEvent = Event(userId: "any_id", title: "Event", description: "", date: .now, location: "", category: .other, latitude: 0, longitude: 0)
                
                // When & Then
                #expect(viewModel.isOwner(of: someEvent) == false)
        }
}
