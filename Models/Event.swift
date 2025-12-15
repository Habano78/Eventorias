//
//  Event.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation

struct Event: Identifiable, Codable, Hashable {
        let id: String
        let userId: String
        var title: String
        var description: String
        var date: Date
        var location: String
        var category: EventCategory
        var imageURL: String?
        var attendees: [String]
        
        // Initialiseur personnalisé pour simplifier la création
        init(id: String = UUID().uuidString,
             userId: String,
             title: String,
             description: String,
             date: Date,
             location: String,
             category: EventCategory,
             imageURL: String? = nil,
             attendees: [String] = []) {
                self.id = id
                self.userId = userId
                self.title = title
                self.description = description
                self.date = date
                self.location = location
                self.category = category
                self.imageURL = imageURL
                self.attendees = attendees
        }
        
}
