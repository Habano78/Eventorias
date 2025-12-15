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
        case book = "Business"
        case film = "Film"
        case charity = "Charity"
        case other = "Other"
        
        var id: String { self.rawValue }
        
        // Associe une icône système à chaque catégorie
        var systemImageName: String {
                switch self {
                case .music: return "music.mic"
                case .art: return "paintpalette"
                case .tech: return "desktopcomputer"
                case .food: return "fork.knife"
                case .book: return "book"
                case .film: return "cinema"
                case .charity: return "heart"
                case .other: return "star"
                }
        }
}
