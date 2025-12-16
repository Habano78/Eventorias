//
//  EventCategory.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation

enum EventCategory: String, CaseIterable, Codable, Identifiable {
        case music = "Music"
        case art = "Art"
        case tech = "Tech"
        case food = "Food"
        case book = "Book"
        case film = "Film"
        case charity = "Charity"
        case other = "Other"
        
        var id: String { self.rawValue }
        
        var assetName: String {
                switch self {
                case .music: return "Event MusicFestival"
                case .art: return "Event ArtExhibition"
                case .tech: return "Event TechConf"
                case .food: return "Event FoodFair"
                case .book: return "Event BookSign"
                case .film: return "Event FilmProyection"
                case .charity: return "Event CarityRun"
                case .other: return "Event TechConf"
                }
        }
}
