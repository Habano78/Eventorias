//
//  UserService.swift
//  Eventorias
//
//  Created by Perez William on 08/01/2026.
//

import Foundation
import FirebaseFirestore

//MARK: Protocole
protocol UserServiceProtocol: Sendable {
        func saveUser(_ user: User) async throws
        func fetchUser(userId: String) async throws -> User?
        func uploadProfileImage(data: Data) async throws -> String
}

//MARK: implementation 
final class UserService: UserServiceProtocol {
        
        private let dataBase = Firestore.firestore()
        
        //MARK: DÉPENDANCE
        private let imageStorageService: ImageStorageServiceProtocol
        
        //MARK: Injection 
        init(imageStorageService: ImageStorageServiceProtocol) {
                self.imageStorageService = imageStorageService
        }
        
        func saveUser(_ user: User) async throws {
                try dataBase.collection("users")
                        .document(user.fireBaseUserId)
                        .setData(from: user, merge: true)
        }
        
        func fetchUser(userId: String) async throws -> User? {
                let snapshot = try await dataBase.collection("users").document(userId).getDocument()
                guard let data = snapshot.data(), snapshot.exists else { return nil }
                
                return User(
                        fireBaseUserId: userId,
                        email: data["email"] as? String ?? "",
                        name: data["name"] as? String,
                        profileImageURL: data["profileImageURL"] as? String,
                        isNotificationsEnabled: data["isNotificationsEnabled"] as? Bool ?? false
                )
        }
        
        func uploadProfileImage(data: Data) async throws -> String {
                let path = "users_avatars/\(UUID().uuidString).jpg"
                return try await imageStorageService.uploadImage(data: data, path: path)
        }
}
