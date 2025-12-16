//
//  Event.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation
import FirebaseFirestore

struct Event: Identifiable, Codable {
        
        @DocumentID var id: String? /// ID  géré automatiquement par Firestore
        
        let userId: String
        let title: String
        let description: String
        let date: Date
        let location: String
        let category: EventCategory
        
        //Init
        init(id: String? = nil, userId: String, title: String, description: String, date: Date, location: String, category: EventCategory) {
                self.id = id
                self.userId = userId
                self.title = title
                self.description = description
                self.date = date
                self.location = location
                self.category = category
        }
}
