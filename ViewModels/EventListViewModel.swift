//
//  EventListViewModel.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation
import Observation
import UserNotifications
import SwiftUI

@MainActor
@Observable
class EventListViewModel {
        
        // MARK: Dépendances
        private let eventService: any EventServiceProtocol
        private let authService: any AuthServiceProtocol
        
        // MARK: Properties
        var events: [Event] = []
        var isLoading = false
        var errorMessage: String?
        var selectedCategory: EventCategory? = nil
        
        var currentUserId: String? {
                return authService.currentUserId
        }
        
        // MARK: Init
        init(
                eventService: any EventServiceProtocol,
                authService: any AuthServiceProtocol
        ) {
                self.eventService = eventService
                self.authService = authService
        }
        
        // MARK: Lecture -Fetch
        func fetchEvents() async {
                isLoading = true
                errorMessage = nil
                do {
                        events = try await eventService.fetchEvents()
                } catch {
                        print("Erreur Fetch : \(error.localizedDescription)")
                        errorMessage = "Erreur de chargement."
                }
                isLoading = false
        }
        
        
        //MARK: Methods
        
        func loadEventsIfNeeded() async {
                if events.isEmpty {
                        await fetchEvents()
                }
        }
        
        //MARK: isOwner 
        func isOwner(of event: Event) -> Bool {
            guard let currentUid = currentUserId else { return false }
            return event.userId == currentUid
        }
        
        
        // MARK: Écriture -Add, Edit, Delete
        
        func addEvent(title: String, description: String, date: Date, location: String, category: EventCategory, latitude: Double, longitude: Double, newImageData: Data?) async {
                guard let uid = currentUserId else { return }
                isLoading = true
                
                do {
                        var imageURL: String? = nil
                        if let imageData = newImageData {
                                imageURL = try await eventService.uploadEventImage(data: imageData)
                        }
                        
                        let newEvent = Event(
                                userId: uid,
                                title: title,
                                description: description,
                                date: date,
                                location: location,
                                category: category,
                                attendees: [uid],
                                imageURL: imageURL,
                                latitude: latitude,
                                longitude: longitude
                        )
                        
                        try await eventService.addEvent(newEvent)
                        await fetchEvents()
                        
                } catch {
                        print("Erreur création : \(error.localizedDescription)")
                        errorMessage = "Impossible de créer l'événement."
                }
                isLoading = false
        }
        
        func editEvent(event: Event, title: String, description: String, date: Date, location: String, category: EventCategory, newImageData: Data?) async {
                self.isLoading = true
                
                do {
                        try await eventService.editEvent(
                                event: event,
                                title: title,
                                description: description,
                                date: date,
                                location: location,
                                category: category,
                                newImageData: newImageData
                        )
                        
                        if let currentUid = currentUserId, event.attendees.contains(currentUid) {
                                cancelNotification(for: event)
                                let updatedEvent = Event(id: event.id, userId: event.userId, title: title, description: description, date: date, location: location, category: category, attendees: event.attendees, imageURL: event.imageURL, latitude: event.latitude, longitude: event.longitude)
                                scheduleNotification(for: updatedEvent)
                        }
                        
                        await fetchEvents()
                } catch {
                        print("Erreur édition : \(error)")
                        errorMessage = "Impossible de modifier l'événement."
                }
                self.isLoading = false
        }
        
        func deleteEvent(_ event: Event) async {
                guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
                
                events.remove(at: index)
                
                do {
                        try await eventService.deleteEvent(eventId: event.id)
                        cancelNotification(for: event)
                } catch {
                        print(" Erreur suppression : \(error)")
                        
                        if index <= self.events.count {
                                events.insert(event, at: index)
                        } else {
                                events.append(event)
                        }
                        
                        errorMessage = "Impossible de supprimer l'événement."
                }
        }
        
        // MARK: Actions Utilisateur -Participation
        
        func toggleParticipation(event: Event) async {
                
                guard let currentUserId = currentUserId else { return }
                guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
                
                let updatedEvent = events[index]
                if updatedEvent.attendees.contains(currentUserId) {
                        updatedEvent.attendees.removeAll { $0 == currentUserId }
                } else {
                        updatedEvent.attendees.append(currentUserId)
                }
                events[index] = updatedEvent
                
                do {
                        let isJoining = updatedEvent.attendees.contains(currentUserId)
                        try await eventService.updateParticipation(eventId: event.id, userId: currentUserId, isJoining: isJoining)
                } catch {
                        events[index] = event
                        self.errorMessage = "Erreur de connexion"
                }
        }
        
        // MARK: - Nettoyage Logout
        func clearData() {
                self.events = []
                self.selectedCategory = nil
                self.errorMessage = nil
                self.isLoading = false
        }
        
        // MARK: Notifications
        private func scheduleNotification(for event: Event) {
                let content = UNMutableNotificationContent()
                content.title = "Rappel : \(event.title)"
                content.body = "Ça commence dans 30 min à \(event.location) !"
                content.sound = .default
                
                let triggerDate = event.date.addingTimeInterval(-1800)
                if triggerDate < Date() { return }
                
                let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
                let request = UNNotificationRequest(identifier: event.id, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
        }
        
        private func cancelNotification(for event: Event) {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.id])
        }
}
