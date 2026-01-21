//
//  UserService.swift
//  Eventorias
//
//  Created by Perez William on 08/01/2026.
//

import Foundation
import FirebaseFirestore

// MARK: Protocole
protocol UserServiceProtocol: Sendable {
        func saveUser(_ user: User) async throws
        func fetchUser(userId: String) async throws -> User?
        func uploadProfileImage(data: Data) async throws -> StorageUploadResult
}

// MARK: Implémentation
final class UserService: UserServiceProtocol {
        
        private let dataBase = Firestore.firestore()
        private let imageStorageService: ImageStorageServiceProtocol
        
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
                guard snapshot.exists else { return nil }
                
                return try? snapshot.data(as: User.self)
        }
        
        func uploadProfileImage(data: Data) async throws -> StorageUploadResult {
                let path = "users_avatars/\(UUID().uuidString).jpg"
                
                return try await imageStorageService.uploadImage(data: data, path: path)
        }
}
