//
//  EventService.swift
//  Eventorias
//
//  Created by Perez William on 08/01/2026.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

// MARK: Contrat
protocol EventServiceProtocol: Sendable {
        func fetchEvents() async throws -> [Event]
        func addEvent(_ event: Event) async throws
        func deleteEvent(eventId: String) async throws
        func editEvent(event: Event, title: String, description: String, date: Date, location: String, category: EventCategory, newImageData: Data?) async throws
        func updateParticipation(eventId: String, userId: String, isJoining: Bool) async throws
        func uploadEventImage(data: Data) async throws -> StorageUploadResult
}


//MARK: Implementation
final class EventService: EventServiceProtocol {
        
        //MARK: dependencies
        private let dataBase = Firestore.firestore()
        private let imageStorageService: ImageStorageServiceProtocol
        
        //MARK: init
        init(imageStorageService: ImageStorageServiceProtocol) {
                self.imageStorageService = imageStorageService
        }
        
        //MARK: actions
        ///
        func fetchEvents() async throws -> [Event] {
                let snapshot = try await dataBase.collection("events").order(by: "date").getDocuments()
                return snapshot.documents.compactMap { doc in
                        guard let dto = try? doc.data(as: EventDTO.self) else { return nil }
                        return Event(dto: dto)
                }
        }
        
        ///
        func addEvent(_ event: Event) async throws {
                let dto = EventDTO(from: event)
                try dataBase.collection("events").document(event.id).setData(from: dto)
        }
        
        ///
        func deleteEvent(eventId: String) async throws {
                try await dataBase.collection("events").document(eventId).delete()
        }
        
        ///
        func editEvent(event: Event, title: String, description: String, date: Date, location: String, category: EventCategory, newImageData: Data?) async throws {
                var data: [String: Any] = [
                        "title": title,
                        "description": description,
                        "date": Timestamp(date: date),
                        "location": location,
                        "category": category.rawValue
                ]
                
                if let imageData = newImageData {
                        if let oldPath = event.imagePath {
                                await imageStorageService.deleteImage(path: oldPath)
                        }
                        
                        let result = try await uploadEventImage(data: imageData)
                        data["imageURL"] = result.url
                        data["imagePath"] = result.path
                }
                
                try await dataBase.collection("events").document(event.id).updateData(data)
        }
        
        ///
        func updateParticipation(eventId: String, userId: String, isJoining: Bool) async throws {
                let data: [String: Any] = isJoining
                ? ["attendees": FieldValue.arrayUnion([userId])]
                : ["attendees": FieldValue.arrayRemove([userId])]
                try await dataBase.collection("events").document(eventId).updateData(data)
        }
        
        ///
        func uploadEventImage(data: Data) async throws -> StorageUploadResult {
                let path = "events_images/\(UUID().uuidString).jpg"
                return try await imageStorageService.uploadImage(data: data, path: path)
        }
}

// MARK: DTOs & Mapping
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
        let imagePath: String?
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
                        imagePath: dto.imagePath,
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
                        imagePath: event.imagePath,
                        latitude: event.latitude,
                        longitude: event.longitude
                )
        }
}
