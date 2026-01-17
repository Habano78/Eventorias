import Foundation

struct Event: Identifiable, Equatable, Hashable, Codable, Sendable {
        
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
        
        // Init
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
}
