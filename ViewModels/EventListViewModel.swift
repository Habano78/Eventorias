//
//  EventListViewModel.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation
import Observation
import UserNotifications

@MainActor
@Observable
class EventListViewModel {
        
        // MARK: - Properties
        var events: [Event] = []
        var isLoading = false
        var errorMessage: String?
        
        var selectedCategory: EventCategory? = nil
        
        private let service: EventServiceProtocol
        
        var currentUserId: String? {
                return service.currentUserId
        }
        
        // MARK: Init
        init(service: EventServiceProtocol) {
                self.service = service
        }
        
        // MARK: Lecture
        func fetchEvents() async {
                isLoading = true
                errorMessage = nil
                do {
                        self.events = try await service.fetchEvents()
                } catch {
                        print("Erreur Fetch : \(error.localizedDescription)")
                        self.errorMessage = "Erreur de chargement."
                }
                isLoading = false
        }
        
        func loadEventsIfNeeded() {
                if events.isEmpty {
                        Task { await fetchEvents() }
                }
        }
        
        // MARK: Écriture
        func addEvent(title: String, description: String, date: Date, location: String, category: EventCategory, latitude: Double, longitude: Double, newImageData: Data?) {
                
                guard let uid = currentUserId else { return }
                self.isLoading = true
                
                Task {
                        do {
                                var imageURL: String? = nil
                                if let imageData = newImageData {
                                        imageURL = try await service.uploadImage(data: imageData)
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
                                
                                try await service.addEvent(newEvent)
                                
                                await fetchEvents()
                                print("Événement créé avec succès (Image: \(imageURL != nil))")
                                
                        } catch {
                                print("Erreur création : \(error.localizedDescription)")
                                self.errorMessage = "Impossible de créer l'événement."
                        }
                        self.isLoading = false
                }
        }
        
        func deleteEvent(_ event: Event) {
                if let index = events.firstIndex(where: { $0.id == event.id }) {
                        events.remove(at: index)
                }
                
                Task {
                        do {
                                try await service.deleteEvent(eventId: event.id)
                                cancelNotification(for: event)
                        } catch {
                                print("Erreur suppression : \(error)")
                                await fetchEvents()
                        }
                }
        }
        // Édition
        func editEvent(event: Event, title: String, description: String, date: Date, location: String, category: EventCategory, newImageData: Data?) {
                self.isLoading = true
                Task {
                        do {
                                try await service.editEvent(
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
                        }
                        self.isLoading = false
                }
        }
        
        // Participation
        func toggleParticipation(event: Event) {
                guard let currentUserId = currentUserId else { return }
                guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
                let liveEvent = events[index]
                
                let isJoining = !liveEvent.attendees.contains(currentUserId)
                
                var updatedAttendees = liveEvent.attendees
                if isJoining {
                        updatedAttendees.append(currentUserId)
                        scheduleNotification(for: liveEvent)
                } else {
                        updatedAttendees.removeAll { $0 == currentUserId }
                        cancelNotification(for: liveEvent)
                }
                
                events[index].attendees = updatedAttendees
                
                Task {
                        do {
                                try await service.updateParticipation(eventId: liveEvent.id, userId: currentUserId, isJoining: isJoining)
                        } catch {
                                await fetchEvents()
                        }
                }
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
