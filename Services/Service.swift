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

final class Service: Sendable {
        
        static let shared = Service()
        
        private lazy var dataBase = Firestore.firestore()
        private lazy var storage = Storage.storage()
        
        var currentUserId: String? {
                return Auth.auth().currentUser?.uid
        }
        
        // MARK: - GESTION ÉVÉNEMENTS (LECTURE)
        
        func fetchEvents() async throws -> [Event] {
                // 1. Appel asynchrone
                let snapshot = try await dataBase.collection("events")
                        .order(by: "date", descending: false)
                        .getDocuments()
                
                let events = snapshot.documents.compactMap { doc -> Event? in
                        guard let dto = try? doc.data(as: EventDTO.self) else { return nil }
                        return Event(from: dto)
                }
                
                return events
        }
        
        // MARK: GESTION ÉVÉNEMENTS (ÉCRITURE)

        func addEvent(_ event: Event) async throws {
                try dataBase.collection("events")
                        .document(event.id)
                        .setData(from: event.asDTO)
        }
        
        func updateEvent(_ event: Event) async throws {
                try dataBase.collection("events")
                        .document(event.id)
                        .setData(from: event.asDTO, merge: true)
        }
        
        func deleteEvent(eventId: String) async throws {
                try await dataBase.collection("events").document(eventId).delete()
        }
        
        //MARK: Modifer
        func updateEvent(event: Event, title: String, description: String, date: Date, location: String, category: EventCategory, newImageData: Data?) async throws {
            
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
            
            try await Firestore.firestore().collection("events").document(event.id).updateData(data)
        }
        
        // MARK: PARTICIPATION
        func updateParticipation(eventId: String, userId: String, isJoining: Bool) async throws {
                let eventRef = dataBase.collection("events").document(eventId)
                
                let data: [String: Any] = isJoining
                ? ["attendees": FieldValue.arrayUnion([userId])]
                : ["attendees": FieldValue.arrayRemove([userId])]
                
                try await eventRef.updateData(data)
        }
        
        // MARK: STORAGE (IMAGES)
        func uploadImage(data: Data) async throws -> String {
                let path = "events_images/\(UUID().uuidString).jpg"
                let fileRef = storage.reference().child(path)
              
                _ = try await fileRef.putDataAsync(data)
                
                let url = try await fileRef.downloadURL()
                return url.absoluteString
        }
        
        // MARK: GESTION USer
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
}
