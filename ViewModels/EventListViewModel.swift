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
        var showSuccessToast = false
        var successMessage = ""
        
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
        
        
        //MARK: Actions
        
        func loadEventsIfNeeded() async {
                if events.isEmpty {
                        await fetchEvents()
                }
        }
        
        
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
        
       
        func isOwner(of event: Event) -> Bool {
                guard let currentUid = currentUserId else { return false }
                return event.userId == currentUid
        }
        
        
        func addEvent(title: String, description: String, date: Date, location: String, category: EventCategory, latitude: Double, longitude: Double, newImageData: Data?) async {
                guard let uid = currentUserId else { return }
                isLoading = true
                
                do {
                        var imageURL: String? = nil
                        var imagePath: String? = nil
                        
                        if let imageData = newImageData {
                                let result = try await eventService.uploadEventImage(
                                        data: imageData
                                )
                                imageURL = result.url
                                imagePath = result.path
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
                                imagePath: imagePath,
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
                
                isLoading = true
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
                        
                        if let currentUid = currentUserId, event.attendees
                                .contains(currentUid) {
                                cancelNotification(for: event)
                                
                                let updatedEvent = Event(
                                        id: event.id,
                                        userId: event.userId,
                                        title: title,
                                        description: description,
                                        date: date,
                                        location: location,
                                        category: category,
                                        attendees: event.attendees,
                                        imageURL: event.imageURL,
                                        imagePath: event.imagePath,
                                        latitude: event.latitude,
                                        longitude: event.longitude
                                )
                                
                                scheduleNotification(for: updatedEvent)
                        }
                        
                        if let index = events.firstIndex(
                                where: { $0.id == event.id
                                }) {
                                
                                var eventToUpdate = events[index]
                                
                                eventToUpdate.title = title
                                eventToUpdate.description = description
                                eventToUpdate.date = date
                                eventToUpdate.location = location
                                eventToUpdate.category = category
                                
                                events[index] = eventToUpdate
                        }
                        
                        await fetchEvents()
                        
                } catch {
                        print("Erreur édition : \(error)")
                        errorMessage = "Impossible de modifier l'événement."
                }
                isLoading = false
        }
        
        func deleteEvent(_ event: Event) async {
                guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
                
                events.remove(at: index)
                
                do {
                        try await eventService.deleteEvent(eventId: event.id)
                        cancelNotification(for: event)
                        
                        successMessage = "Événement supprimé avec succès"
                        showSuccessToast = true
                        
                        Task {
                                try? await Task.sleep(nanoseconds: 3_000_000_000)
                                showSuccessToast = false
                        }
                        
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
                guard let index = events.firstIndex(where: { $0.id == event.id }) else {
                        return
                }
                
                var updatedEvent = events[index]
                
                if updatedEvent.attendees.contains(currentUserId) {
                        updatedEvent.attendees.removeAll { $0 == currentUserId }
                } else {
                        updatedEvent.attendees.append(currentUserId)
                }
                
                events[index] = updatedEvent
                
                do {
                        let isJoining = updatedEvent.attendees.contains(
                                currentUserId
                        )
                        try await eventService
                                .updateParticipation(
                                        eventId: event.id,
                                        userId: currentUserId,
                                        isJoining: isJoining
                                )
                } catch {
                        events[index] = event
                        errorMessage = "Impossible de modifier la participation."
                }
        }
        
        
        // MARK: Nettoyage Logout
        func clearData() {
                events = []
                selectedCategory = nil
                errorMessage = nil
                isLoading = false
        }
        
        // MARK: Notifications
        private func scheduleNotification(for event: Event) {
                let content = UNMutableNotificationContent()
                content.title = "Rappel : \(event.title)"
                content.body = "Ça commence dans 30 min à \(event.location) !"
                content.sound = .default
                
                let triggerDate = event.date.addingTimeInterval(-1800)
                if triggerDate < Date() { return }
                
                let comps = Calendar.current.dateComponents(
                        [.year, .month, .day, .hour, .minute],
                        from: triggerDate
                )
                let trigger = UNCalendarNotificationTrigger(
                        dateMatching: comps,
                        repeats: false
                )
                let request = UNNotificationRequest(
                        identifier: event.id,
                        content: content,
                        trigger: trigger
                )
                
                UNUserNotificationCenter.current().add(request)
        }
        
        //
        private func cancelNotification(for event: Event) {
                UNUserNotificationCenter
                        .current()
                        .removePendingNotificationRequests(
                                withIdentifiers: [event.id]
                        )
        }
}
