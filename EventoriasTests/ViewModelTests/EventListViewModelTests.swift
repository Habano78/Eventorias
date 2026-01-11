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
        
        @Test
        func fetchEventsSuccess() async {
                let event = Event(userId: "u1", title: "Party", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                
                await confirmation("Fetch events completes") { confirm in
                        mockEventService.onFetchEvents = { confirm() }
                        await viewModel.fetchEvents()
                }
                
                await Task.yield()
                #expect(viewModel.events.count == 1)
                #expect(viewModel.isLoading == false)
        }
        
        @Test
        func fetchEventsFailure() async {
                mockEventService.shouldReturnError = true
                
                await confirmation("Fetch events fails") { confirm in
                        mockEventService.onFetchEvents = { confirm() }
                        await viewModel.fetchEvents()
                }
                
                await Task.yield()
                #expect(viewModel.events.isEmpty)
                #expect(viewModel.errorMessage != nil)
        }
        
        @Test
        func loadEventsTrigger() async throws {
                viewModel.events = []
                let event = Event(userId: "u1", title: "Loaded", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                
                await confirmation("LoadIfNeeded triggers fetch") { confirm in
                        mockEventService.onFetchEvents = { confirm() }
                        await viewModel.loadEventsIfNeeded()
                }
                
                await Task.yield()
                #expect(viewModel.events.count == 1)
        }
        
        @Test
        func addEventWithImage() async throws {
                mockAuthService.mockUserId = "user_123"
                let fakeImageData = Data([0x00, 0x01, 0x02])
                
                await confirmation("Add event with image completes") { confirm in
                        mockEventService.onAddEvent = { confirm() }
                        await viewModel.addEvent(
                                title: "Avec Image",
                                description: "Desc",
                                date: Date(),
                                location: "Loc",
                                category: .art,
                                latitude: 0,
                                longitude: 0,
                                newImageData: fakeImageData
                        )
                }
                
                await Task.yield()
                
                let addedEvent = try #require(viewModel.events.first)
                // L'URL ici matche maintenant celle du Mock (fixée à "https://mock.com/event.jpg")
                #expect(addedEvent.imageURL == "https://mock.com/event.jpg")
        }
        
        @Test
        func addEventFailure() async throws {
                mockAuthService.mockUserId = "me"
                mockEventService.shouldReturnError = true
                
                await confirmation("Add event fails") { confirm in
                        mockEventService.onAddEvent = { confirm() }
                        await viewModel.addEvent(title: "New", description: "", date: Date(), location: "", category: .art, latitude: 0, longitude: 0, newImageData: nil)
                }
                
                await Task.yield()
                #expect(viewModel.events.isEmpty)
                #expect(viewModel.errorMessage == "Impossible de créer l'événement.")
        }
        
        @Test
        func deleteEventSuccessExecution() async throws {
                let event = Event(userId: "u1", title: "To Delete", description: "", date: Date(), location: "", category: .other, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                let targetEvent = try #require(viewModel.events.first)
                
                await confirmation("Delete event completes") { confirm in
                        mockEventService.onDeleteEvent = { confirm() }
                        await viewModel.deleteEvent(targetEvent)
                }
                
                await Task.yield()
                #expect(viewModel.events.isEmpty)
        }
        
        @Test
        func deleteEventRollback() async throws {
                let event = Event(userId: "u1", title: "To Delete", description: "", date: Date(), location: "", category: .other, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                
                mockEventService.shouldReturnError = true
                
                await confirmation("Delete event fails") { confirm in
                        mockEventService.onDeleteEvent = { confirm() }
                        // On attend la fin complète (y compris rollback)
                        await viewModel.deleteEvent(event)
                }
                
                await Task.yield()
                
                // Vérif après rollback : L'élément doit être revenu
                #expect(viewModel.events.count == 1)
                #expect(viewModel.events.first?.title == "To Delete")
        }
        
        @Test
        func toggleParticipationFailure() async throws {
                mockAuthService.mockUserId = "user_123"
                let event = Event(userId: "host", title: "Party", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                let targetEvent = try #require(viewModel.events.first)
                
                mockEventService.shouldReturnError = true
                
                await confirmation("Toggle participation fails") { confirm in
                        mockEventService.onUpdateParticipation = { confirm() }
                        await viewModel.toggleParticipation(event: targetEvent)
                }
                
                await Task.yield()
                
                // Comme le toggle échoue, le VM tente un fetchEvents. Le mock étant en erreur, le fetch échoue aussi.
                // Donc on aura un message d'erreur.
                #expect(viewModel.errorMessage != nil)
        }
        
        @Test
        func editEventFailure() async throws {
                let event = Event(userId: "u1", title: "Avant", description: "", date: Date(), location: "", category: .music, latitude: 0, longitude: 0)
                mockEventService.mockEvents = [event]
                await viewModel.fetchEvents()
                let eventToEdit = try #require(viewModel.events.first)
                mockEventService.shouldReturnError = true
                
                await confirmation("Edit event fails") { confirm in
                        mockEventService.onEditEvent = { confirm() }
                        await viewModel.editEvent(
                                event: eventToEdit,
                                title: "Crash",
                                description: "",
                                date: Date(),
                                location: "",
                                category: .music,
                                newImageData: nil
                        )
                }
                
                await Task.yield()
                #expect(viewModel.isLoading == false)
        }
}
