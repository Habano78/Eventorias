//
//  Service.swift
//  Eventorias
//
//  Created by Perez William on 16/12/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

// MARK: PROTOCOLE
protocol EventServiceProtocol: Sendable {
        
        var currentUserId: String? { get }
        
        func fetchEvents() async throws -> [Event]
        func addEvent(_ event: Event) async throws
        func updateEvent(_ event: Event) async throws
        func deleteEvent(eventId: String) async throws
        func editEvent(event: Event, title: String, description: String, date: Date, location: String, category: EventCategory, newImageData: Data?) async throws
        
        func updateParticipation(eventId: String, userId: String, isJoining: Bool) async throws
       
        func uploadImage(data: Data) async throws -> String
        
        func saveUser(_ user: User) async throws
        func fetchUser(userId: String) async throws -> User?
        
        //Tests Auth
        func signIn(email: String, password: String) async throws -> String
        func signUp(email: String, password: String) async throws -> String
        func signOut() throws
}


// MARK: IMPLEMENTATION
@MainActor
final class Service: EventServiceProtocol {
        
        static let shared = Service()
        
        private lazy var dataBase = Firestore.firestore()
        private lazy var storage = Storage.storage()
        
        var currentUserId: String? {
                return Auth.auth().currentUser?.uid
        }
        
        // MARK: GESTION ÉVÉNEMENTS
        func fetchEvents() async throws -> [Event] {
                let snapshot = try await dataBase.collection("events")
                        .order(by: "date")
                        .getDocuments()
                
                return snapshot.documents.compactMap { doc in
                        guard let dto = try? doc.data(as: EventDTO.self) else { return nil }
                        return Event(dto: dto)
                }
        }
        
        func addEvent(_ event: Event) async throws {
                let dto = EventDTO(from: event)
                try dataBase.collection("events")
                        .document(event.id)
                        .setData(from: dto)
        }
        
        
        func updateEvent(_ event: Event) async throws {
                let dto = EventDTO(from: event)
                try dataBase.collection("events")
                        .document(event.id)
                        .setData(from: dto, merge: true)
        }
        
        
        func deleteEvent(eventId: String) async throws {
                try await dataBase.collection("events").document(eventId).delete()
        }
        
        // MARK: ÉDITION COMPLEXE
        
        func editEvent(event: Event, title: String, description: String, date: Date, location: String, category: EventCategory, newImageData: Data?) async throws {
                
                var data: [String: Any] = [
                        "title": title,
                        "description": description,
                        "date": Timestamp(date: date),
                        "location": location,
                        "category": category.rawValue
                ]
                
                if let imageData = newImageData {
                        let newImageURL = try await uploadImage(data: imageData)
                        data["imageURL"] = newImageURL
                }
                
                try await dataBase
                        .collection("events")
                        .document(event.id)
                        .updateData(data)
        }
        
        // MARK: PARTICIPATION
        
        func updateParticipation(eventId: String, userId: String, isJoining: Bool) async throws {
                let eventRef = dataBase
                        .collection("events")
                        .document(eventId)
                
                let data: [String: Any] = isJoining
                ? ["attendees": FieldValue.arrayUnion([userId])]
                : ["attendees": FieldValue.arrayRemove([userId])]
                
                try await eventRef.updateData(data)
        }
        
        // MARK: STORAGE
        
        func uploadImage(data: Data) async throws -> String {
                let path = "events_images/\(UUID().uuidString).jpg"
                let fileRef = storage.reference().child(path)
                
                _ = try await fileRef.putDataAsync(data)
                
                let url = try await fileRef.downloadURL()
                return url.absoluteString
        }
        
        // MARK: GESTION USER
        
        func saveUser(_ user: User) async throws {
                try dataBase.collection("users")
                        .document(user.fireBaseUserId)
                        .setData(from: user, merge: true)
        }
        
        func fetchUser(userId: String) async throws -> User? {
                let snapshot = try await dataBase.collection("users").document(userId).getDocument()
                
                guard let data = snapshot.data(), snapshot.exists else {
                        return nil
                }
                
                return User(
                        fireBaseUserId: userId,
                        email: data["email"] as? String ?? "",
                        name: data["name"] as? String,
                        profileImageURL: data["profileImageURL"] as? String,
                        isNotificationsEnabled: data["isNotificationsEnabled"] as? Bool ?? false
                )
        }
        
        //Tests Auth
        func signIn(email: String, password: String) async throws -> String {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                return result.user.uid
            }
            
            func signUp(email: String, password: String) async throws -> String {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                return result.user.uid
            }
            
            func signOut() throws {
                try Auth.auth().signOut()
            }
}


// MARK: - DTO
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
        convenience init(dto: EventDTO) {
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
