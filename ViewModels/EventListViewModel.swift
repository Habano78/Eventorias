//
//  EventListViewModel.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//


import Foundation
import Observation

@Observable
class EventListViewModel {
        var events: [Event] = []
        
        init() {
                loadMockData()
        }
        
        func loadMockData() {
                self.events = [
                        Event(
                                userId: UUID().uuidString, // Correction : userId
                                title: "Exposition d'Art Moderne",
                                description: "Une rétrospective complète des œuvres du 20ème siècle.", // Ajouté car obligatoire
                                date: Date(),
                                location: "Paris, Le Louvre",
                                category: .art
                        ),
                        Event(
                                userId: UUID().uuidString,
                                title: "Festival de Musique",
                                description: "Trois jours de concerts en plein air avec des artistes internationaux.",
                                date: Date().addingTimeInterval(86400 * 3), // Dans 3 jours
                                location: "Lyon, Parc de la Tête d'Or",
                                category: .music
                        ),
                        Event(
                                userId: UUID().uuidString,
                                title: "Marathon Caritatif",
                                description: "Course pour soutenir la recherche médicale.",
                                date: Date().addingTimeInterval(86400 * 10),
                                location: "Bordeaux, Centre Ville",
                                category: .charity
                        )
                ]
        }
}
