//
//  EventListViewModelTests.swift
//  EventoriasTests
//
//  Created by Perez William on 07/01/2026.
//

import Testing
import Foundation
import FirebaseCore
@testable import Eventorias


@MainActor
struct EventListViewModelTests {
        
        let viewModel: EventListViewModel
        let mockService: MockEventService
        
        
        init() {
                if FirebaseApp.app() == nil {
                        FirebaseApp.configure()
                }
                self.mockService = MockEventService()
                self.viewModel = EventListViewModel(service: mockService)
        }
        
        //MARK: tests
        
        @Test("Chargement réussi des événements")
        func fetchEventsSuccess() async {
                // GIVEN
                let event = Event(userId: "u1", title: "Test Party", description: "Fun", date: Date(), location: "Paris", category: .music, latitude: 0, longitude: 0)
                mockService.mockEvents = [event]
                
                // WHEN
                await viewModel.fetchEvents()
                
                // THEN
                #expect(viewModel.isLoading == false)
                #expect(viewModel.events.count == 1)
                #expect(viewModel.events.first?.title == "Test Party")
        }
        
        // MARK: Test d'Ajout
        @Test("Ajout d'un événement (Scénario nominal)")
        func addEventSuccess() async throws {
                // GIVEN
                mockService.mockEvents = []
                
                // WHEN
                // On simule l'ajout via le ViewModel
                viewModel.addEvent(
                        title: "Nouvel An",
                        description: "Champagne !",
                        date: Date(),
                        location: "Lyon",
                        category: .sport,
                        latitude: 0,
                        longitude: 0,
                        newImageData: nil
                )
                
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // THEN
                ///vérifier que le service a reçu l'info
                #expect(mockService.mockEvents.count == 1)
                
                ///vérifier que le ViewModel s'est mis à jour (car il refetch après ajout)
                #expect(viewModel.events.count == 1)
                
                ///vérifier le contenu (on utilise #require pour déballer l'optionnel de façon sûre)
                let addedEvent = try #require(viewModel.events.first)
                #expect(addedEvent.title == "Nouvel An")
        }
        
        
        @Test("Suppression d'un événement")
        func deleteEventSuccess() async throws {
                // GIVEN
                let event = Event(userId: "u1", title: "À supprimer", description: "", date: Date(), location: "", category: .other, latitude: 0, longitude: 0)
                mockService.mockEvents = [event]
                await viewModel.fetchEvents() // On charge l'état initial
                
                #expect(viewModel.events.count == 1) // Vérification pré-condition
                
                // WHEN
                viewModel.deleteEvent(event)
                
                // ATTENTE (Task interne)
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // THEN
                #expect(mockService.mockEvents.isEmpty)
                #expect(viewModel.events.isEmpty)
        }
        
        
        @Test("Modification d'un événement")
        func editEventSuccess() async throws {
                // GIVEN
                let event = Event(userId: "u1", title: "Avant", description: "Old", date: Date(), location: "Paris", category: .music, latitude: 0, longitude: 0)
                mockService.mockEvents = [event]
                await viewModel.fetchEvents()
                
                let eventToEdit = try #require(viewModel.events.first)
                
                // WHEN
                viewModel.editEvent(
                        event: eventToEdit,
                        title: "Après",
                        description: "New",
                        date: Date(),
                        location: "Paris",
                        category: .music,
                        newImageData: nil
                )
                
                // ATTENTE
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // THEN
                let editedEvent = try #require(viewModel.events.first)
                #expect(editedEvent.title == "Après")
                #expect(editedEvent.description == "New")
        }
}
