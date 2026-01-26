//
//  EventCategory.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

enum EventCategory: String, CaseIterable, Codable, Identifiable, Hashable {
        case music = "Music"
        case art = "Art"
        case tech = "Tech"
        case food = "Food"
        case book = "Book"
        case film = "Film"
        case sport = "Sport"
        case other = "Other"
        
        var id: String { self.rawValue }
        
        // MARK: Assets
        var assetName: String {
                switch self {
                case .music: return "Event MusicFestival"
                case .art: return "Event ArtExhibition"
                case .tech: return "Event TechConf"
                case .food: return "Event FoodFair"
                case .book: return "Event BookSign"
                case .film: return "Event FilmProyection"
                case .sport: return "Event CarityRun"
                case .other: return "Event TechConf"
                }
        }
}

// MARK: UI Helpers - Couleurs et Icônes SF Symbols
extension EventCategory {
        
        var iconName: String {
                switch self {
                case .music: return "music.mic"
                case .sport: return "figure.run"
                case .book: return "paintpalette.fill"
                case .art: return "party.popper.fill"
                case .tech: return "bolt.fill"
                case .film: return "book.fill"
                case .food: return "gift.fill"
                case .other: return "questionmark.circle.fill"
                }
        }
        
        var color: Color {
                switch self {
                case .music: return .purple
                case .sport: return .orange
                case .book: return .red
                case .art: return .pink
                case .food: return .cyan
                case .tech: return .yellow
                case .film: return .green
                case .other: return .gray
                }
        }
}
