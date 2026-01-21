//
//  User.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation

struct User: Identifiable, Codable, Sendable, Equatable {
        
        let fireBaseUserId: String
        let email: String
        var name: String?
        var profileImageURL: String?
        var profileImagePath: String?
        var isNotificationsEnabled: Bool = false
        
        var id: String {
                return fireBaseUserId
        }
        
        
        init(fireBaseUserId: String, email: String, name: String? = nil, profileImageURL: String? = nil, profileImagePath: String?, isNotificationsEnabled: Bool = false) {
                self.fireBaseUserId = fireBaseUserId
                self.email = email
                self.name = name
                self.profileImageURL = profileImageURL
                self.profileImagePath = profileImagePath
                self.isNotificationsEnabled = isNotificationsEnabled
        }
}
