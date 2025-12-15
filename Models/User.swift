//
//  User.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation

struct User: Identifiable, Codable {
        
        let fireBaseId: String
        let email: String
        var name: String?
        var profileImageURL: String?
        var isNotificationsEnabled: Bool = false
        
        var id: String {
                return fireBaseId
        }
        
        //Init
        init(fireBaseId: String, email: String, name: String? = nil, profileImageURL: String? = nil) {
                self.fireBaseId = fireBaseId
                self.email = email
                self.name = name
                self.profileImageURL = profileImageURL
        }
}
