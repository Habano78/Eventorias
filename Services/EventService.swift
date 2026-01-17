//
//  EventService.swift
//  Eventorias
//
//  Created by Perez William on 08/01/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

// MARK: - Protocol
protocol EventServiceProtocol: Sendable {
        func fetchEvents() async throws -> [Event]
        func addEvent(_ event: Event) async throws
        func deleteEvent(eventId: String) async throws
        func editEvent(event: Event, title: String, description: String, date: Date, location: String, category: EventCategory, newImageData: Data?) async throws
        func updateParticipation(eventId: String, userId: String, isJoining: Bool) async throws
        func uploadEventImage(data: Data) async throws -> String
}

// MARK: - Implementation
final class EventService: EventServiceProtocol {
        
        //MARK: Dependences
        private let dataBase = Firestore.firestore()
        private let imageStorageService: ImageStorageServiceProtocol
        
        
        //MARK: Init
        init(imageStorageService: ImageStorageServiceProtocol) {
                self.imageStorageService = imageStorageService
        }
        
        
        //MARK: Methodes
        func fetchEvents() async throws -> [Event] {
                let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
                let snapshot = try await dataBase.collection("events")
                        .whereField("date", isGreaterThan: sevenDaysAgo)
                        .order(by: "date", descending: false)
                        .limit(to: 50)
                        .getDocuments()
                /// Mapping des données
                return snapshot.documents.compactMap { doc in
                        
                        do {
                                let dto = try doc.data(as: EventDTO.self)
                                return Event(dto: dto)
                                
                        } catch {
                                print("ERREUR CRITIQUE sur l'event ID : \(doc.documentID)")
                                print("Détail de l'erreur : \(error)")
                                
                                return nil
                        }
                }
        }
        
        func addEvent(_ event: Event) async throws {
                let dto = EventDTO(from: event)
                try dataBase.collection("events").document(event.id).setData(from: dto)
        }
        
        func deleteEvent(eventId: String) async throws {
                try await dataBase.collection("events").document(eventId).delete()
        }
        
        func editEvent(event: Event, title: String, description: String, date: Date, location: String, category: EventCategory, newImageData: Data?) async throws {
                var data: [String: Any] = [
                        "title": title,
                        "description": description,
                        "date": Timestamp(date: date),
                        "location": location,
                        "category": category.rawValue
                ]
                
                if let imageData = newImageData {
                        let newImageURL = try await uploadEventImage(data: imageData)
                        data["imageURL"] = newImageURL
                }
                
                try await dataBase.collection("events").document(event.id).updateData(data)
        }
        
        func updateParticipation(eventId: String, userId: String, isJoining: Bool) async throws {
                let data: [String: Any] = isJoining
                ? ["attendees": FieldValue.arrayUnion([userId])]
                : ["attendees": FieldValue.arrayRemove([userId])]
                
                try await dataBase.collection("events").document(eventId).updateData(data)
        }
        
        func uploadEventImage(data: Data) async throws -> String {
                let path = "events_images/\(UUID().uuidString).jpg"
                // Délégation
                return try await imageStorageService.uploadImage(data: data, path: path)
        }
}

// MARK: DTOs
private struct EventDTO: Codable, Identifiable {
        @DocumentID var id: String?
        let userId: String
        let title: String
        let description: String
        let date: Date
        let location: String
        let category: EventCategory
        let attendees: [String]
        let imageURL: String?
        let latitude: Double
        let longitude: Double
}

private extension Event {
        init(dto: EventDTO) {
                self.init(
                        id: dto.id ?? UUID().uuidString,
                        userId: dto.userId,
                        title: dto.title,
                        description: dto.description,
                        date: dto.date,
                        location: dto.location,
                        category: dto.category,
                        attendees: dto.attendees,
                        imageURL: dto.imageURL,
                        latitude: dto.latitude,
                        longitude: dto.longitude
                )
        }
}

private extension EventDTO {
        init(from event: Event) {
                self.init(
                        id: event.id,
                        userId: event.userId,
                        title: event.title,
                        description: event.description,
                        date: event.date,
                        location: event.location,
                        category: event.category,
                        attendees: event.attendees,
                        imageURL: event.imageURL,
                        latitude: event.latitude,
                        longitude: event.longitude
                )
        }
}
