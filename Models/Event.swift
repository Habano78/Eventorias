import Foundation
import Observation

@Observable
final class Event: Identifiable, Equatable, Hashable {
        
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
        
        init(
                id: String = UUID().uuidString,
                userId: String,
                title: String,
                description: String,
                date: Date,
                location: String,
                category: EventCategory,
                attendees: [String] = [],
                imageURL: String? = nil,
                latitude: Double,
                longitude: Double
        ) {
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
        
        // MARK: Equatable & Hashable
        
        static func == (lhs: Event, rhs: Event) -> Bool {
                lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
                hasher.combine(id)
        }
}
