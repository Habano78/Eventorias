//
//  EventListViewModel.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//


import Foundation
import Observation
import FirebaseFirestore

@Observable
class EventListViewModel {
        
        var events: [Event] = []
        
        private var dataBase = Firestore.firestore()
        
        //MARK: init
        init() {
                fetchEvents()
        }
        
        // MARK: Récupération
        func fetchEvents() {
                
                dataBase.collection("events").addSnapshotListener { [weak self] snapshot, error in
                        
                        // Gestion des erreurs
                        if let error = error {
                                print("❌ Erreur de chargement Firestore: \(error.localizedDescription)")
                                return
                        }
                        
                        // Vérification
                        guard let documents = snapshot?.documents else {
                                print("⚠️ Aucun document trouvé")
                                return
                        }
                        
                        // On transforme les documents bruts de Firestore en objets "Event" Swift
                        self?.events = documents.compactMap { doc -> Event? in
                                try? doc.data(as: Event.self)
                        }
                }
        }
        
        // MARK: - Ajout (Écriture)
        // Dans EventListViewModel.swift
        
        // Changez la signature de la fonction pour accepter 'userId'
        func addEvent(title: String, description: String, date: Date, location: String, category: EventCategory, userId: String) {
                
                let newEvent = Event(
                        // Plus de "CurrentUser" en dur ! On utilise le vrai ID reçu
                        userId: userId,
                        title: title,
                        description: description,
                        date: date,
                        location: location,
                        category: category
                )
                
                do {
                        // Le reste ne change pas
                        try dataBase.collection("events").addDocument(from: newEvent)
                        print("✅ Événement ajouté pour l'user \(userId)")
                } catch {
                        print("❌ Erreur : \(error.localizedDescription)")
                }
        }
}
