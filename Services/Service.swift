//
//  Service.swift
//  Eventorias
//
//  Created by Perez William on 16/12/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth // INDISPENSABLE pour currentUserId

class Service {
        
        private let dataBase = Firestore.firestore()
        
        var currentUserId: String? {
                return Auth.auth().currentUser?.uid
        }
        
        // MARK: GESTION ÉVÉNEMENTS
        func fetchEvents(completion: @escaping ([Event]) -> Void) {
                dataBase.collection("events").order(by: "date", descending: false).getDocuments { snapshot, error in
                        guard let documents = snapshot?.documents, error == nil else {
                                print("Erreur Fetch: \(error?.localizedDescription ?? "Inconnue")")
                                completion([])
                                return
                        }
                        
                        let events = documents.compactMap { doc -> Event? in
                                try? doc.data(as: Event.self)
                        }
                        completion(events)
                }
        }
        
        func addEvent(event: Event, completion: @escaping (Bool) -> Void) {
                do {
                        try dataBase.collection("events").addDocument(from: event)
                        completion(true)
                } catch {
                        print("Erreur ajout: \(error.localizedDescription)")
                        completion(false)
                }
        }
        
        // ✅ CORRECTION 3 : La fonction updateEvent manquante
        func updateEvent(event: Event, completion: @escaping (Bool) -> Void) {
                guard let eventId = event.id else { return }
                
                do {
                        try dataBase.collection("events").document(eventId).setData(from: event, merge: true)
                        completion(true)
                } catch {
                        print("Erreur update event: \(error.localizedDescription)")
                        completion(false)
                }
        }
        
        func deleteEvent(eventId: String, completion: @escaping (Bool) -> Void) {
                dataBase.collection("events").document(eventId).delete { error in
                        completion(error == nil)
                }
        }
        
        // MARK: - PARTICIPATION
        
        func updateParticipation(eventId: String, userId: String, isJoining: Bool, completion: @escaping (Bool) -> Void) {
                let eventRef = dataBase.collection("events").document(eventId)
                
                let data: [String: Any] = isJoining
                ? ["attendees": FieldValue.arrayUnion([userId])]
                : ["attendees": FieldValue.arrayRemove([userId])]
                
                eventRef.updateData(data) { error in
                        completion(error == nil)
                }
        }
        
        // MARK: - STORAGE (IMAGES)
        
        func uploadImage(data: Data, completion: @escaping (String?) -> Void) {
                let storageRef = Storage.storage().reference()
                let path = "events_images/\(UUID().uuidString).jpg"
                let fileRef = storageRef.child(path)
                
                fileRef.putData(data, metadata: nil) { metadata, error in
                        if let error = error {
                                print("Erreur upload: \(error.localizedDescription)")
                                completion(nil)
                                return
                        }
                        
                        fileRef.downloadURL { url, error in
                                if let error = error {
                                        print("Erreur URL: \(error.localizedDescription)")
                                        completion(nil)
                                        return
                                }
                                completion(url?.absoluteString)
                        }
                }
        }
        
        // MARK: - GESTION USER
        
        func saveUser(_ user: User, completion: @escaping (Bool) -> Void) {
                do {
                        try dataBase.collection("users").document(user.fireBaseUserId).setData(from: user, merge: true)
                        completion(true)
                } catch {
                        print("Erreur sauvegarde user: \(error.localizedDescription)")
                        completion(false)
                }
        }
        
        func fetchUser(userId: String, completion: @escaping (User?) -> Void) {
                dataBase.collection("users").document(userId).getDocument { snapshot, error in
                        
                        guard let snapshot = snapshot,
                              snapshot.exists,
                              let data = snapshot.data() else {
                                completion(nil)
                                return
                        }
                        
                        /// On construit l'objet User pour éviter l'erreur "Decodable isolated context"
                        let user = User(
                                fireBaseUserId: userId,
                                email: data["email"] as? String ?? "",
                                name: data["name"] as? String,
                                profileImageURL: data["profileImageURL"] as? String,
                                isNotificationsEnabled: data["isNotificationsEnabled"] as? Bool ?? false
                        )
                        
                        completion(user)
                }
        }
}
