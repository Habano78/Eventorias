//
//  Event.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation
import FirebaseFirestore
import Observation

// MARK: DTO
struct EventDTO: Codable, Identifiable, Sendable {
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

// MARK: Modèle métier
@Observable
class Event: Identifiable, Encodable, Equatable, Hashable {
        let id: String
        let userId: String
        var title: String
        var description: String
        var date: Date
        var location: String
        var category: EventCategory
        var attendees: [String]
        var imageURL: String?
        var latitude: Double
        var longitude: Double
        
        //
        init(id: String = UUID().uuidString, userId: String, title: String, description: String, date: Date, location: String, category: EventCategory, attendees: [String] = [], imageURL: String? = nil, latitude: Double, longitude: Double) {
                self.id = id
                self.userId = userId
                self.title = title
                self.description = description
                self.date = date
                self.location = location
                self.category = category
                self.attendees = attendees
                self.imageURL = imageURL
                self.latitude = latitude
                self.longitude = longitude
        }
        
        init(from dto: EventDTO) {
                self.id = dto.id ?? UUID().uuidString
                self.userId = dto.userId
                self.title = dto.title
                self.description = dto.description
                self.date = dto.date
                self.location = dto.location
                self.category = dto.category
                self.attendees = dto.attendees
                self.imageURL = dto.imageURL
                self.latitude = dto.latitude
                self.longitude = dto.longitude
        }
        
        // MARK: - Equatable & Hashable
        
        static func == (lhs: Event, rhs: Event) -> Bool {
                return lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
                hasher.combine(id)
        }
}

extension Event {
        // Propriété calculée pour reconvertir l'objet UI en DTO pour l'envoi vers Firebase
        var asDTO: EventDTO {
                EventDTO(
                        id: id,
                        userId: userId,
                        title: title,
                        description: description,
                        date: date,
                        location: location,
                        category: category,
                        attendees: attendees,
                        imageURL: imageURL,
                        latitude: latitude,
                        longitude: longitude
                )
        }
}
