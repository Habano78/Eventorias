//
//  Service.swift
//  Eventorias
//
//  Created by Perez William on 16/12/2025.
//


import Foundation
import FirebaseFirestore


class Service {
        
        private let dataBase = Firestore.firestore()
        
        // MARK: Lecture
        func listenToEvents(completion: @escaping ([Event]) -> Void) {
                dataBase.collection("events").addSnapshotListener { snapshot, error in
                        guard let documents = snapshot?.documents, error == nil else {
                                print("Erreur Service: \(error?.localizedDescription ?? "Inconnue")")
                                return
                        }
                        
                        let events = documents.compactMap { doc -> Event? in
                                try? doc.data(as: Event.self)
                        }
                        
                        completion(events)
                }
        }
        
        // MARK: ajout
        func add(_ event: Event) {
                do {
                        try dataBase.collection("events").addDocument(from: event)
                } catch {
                        print("Erreur ajout: \(error.localizedDescription)")
                }
        }
        
        // MARK: suppression
        func delete(eventId: String) {
                dataBase.collection("events").document(eventId).delete()
        }
        
        // MARK: Participation
        func updateParticipation(eventId: String, userId: String, isJoining: Bool) {
                
                let eventRef = dataBase.collection("events").document(eventId)
                
                if isJoining {
                        eventRef.updateData([
                                "attendees": FieldValue.arrayUnion([userId])
                        ])
                } else {
                        eventRef.updateData([
                                "attendees": FieldValue.arrayRemove([userId])
                        ])
                }
        }
}
