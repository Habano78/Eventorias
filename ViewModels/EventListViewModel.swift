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
        
        //MARK: property
        var events: [Event] = []
        
        //MARK: init
        init() {
                loadMockData()
        }
        
        //MARK: fetch
        func loadMockData() {
                
                self.events = [
                        Event(
                                userId: UUID().uuidString,
                                title: "Exposition d'Art Moderne",
                                description: "Join us for an exclusive Art Exhibition showcasing the works of the talented artist Emily Johnson. This exhibition will feature a captivating collection of her contemporary and classical pieces, offering a unique insight into her creative journey. Whether you're an art enthusiast or a casual visitor, you'll have the chance to explore a diverse range of artworks.",
                                date: Date(),
                                location: "123 Rue de l'Art, Quartier des Galeries, Paris, 75003, France)",
                                category: .art
                        ),
                        Event(
                                userId: UUID().uuidString,
                                title: "Festival de Musique",
                                description: "Trois jours de concerts en plein air avec des artistes internationaux.",
                                date: Date().addingTimeInterval(86400 * 3), //j+3
                                location: "Lyon, Parc de la Tête d'Or",
                                category: .music
                        ),
                        Event(
                                userId: UUID().uuidString,
                                title: "Marathon Caritatif",
                                description: "Course pour soutenir la recherche médicale.",
                                date: Date().addingTimeInterval(86400 * 10), //J+10
                                location: "Bordeaux, Centre Ville",
                                category: .charity
                        ),
                        Event(
                                userId: UUID().uuidString,
                                title: "Tech conference",
                                description: "Présentation des dernières mises à jour de l'iOS et d'autres technologies  .",
                                date: Date().addingTimeInterval(86400 * 6),
                                location: "Paris, Musee des Arts et Métiers",
                                category: .tech
                        ),
                        Event(
                                userId: UUID().uuidString,
                                title: "Projection du film '2001: A Space Odyssey'",
                                description: "Une rétrospective complète des œuvres du 20ème siècle.",
                                date: Date().addingTimeInterval(86400 * 15),
                                location: "Paris, Le Louvre",
                                category: .film
                        )
                ]
        }
        
        //MARK: ajout
        func addEvent(title: String, description: String, date: Date, location: String, category: EventCategory) {
            
            // Création de l'objet Event
            let newEvent = Event(
                userId: "CurrentUser", // Temporaire
                title: title,
                description: description,
                date: date,
                location: location,
                category: category
            )
            self.events.insert(newEvent, at: 0) /// Ajout au début du tableau
        }
}
