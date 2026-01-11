//
//  MockUserService.swift
//  EventoriasTests
//
//  Created by Perez William on 08/01/2026.
//

import Foundation
@testable import Eventorias

@MainActor
final class MockUserService: UserServiceProtocol {
        
        // MARK: State
        var mockUser: User?
        var shouldReturnError = false
        
        // MARK: - Hooks
        var onFetchUser: (() -> Void)?
        var onSaveUser: (() -> Void)?
        var onUploadImage: (() -> Void)?
        
        
        // MARK: Implementation
        
        func saveUser(_ user: User) async throws {
                defer { onSaveUser?() } // 🛡️ Sera appelé même si erreur ligne suivante
                
                if shouldReturnError { throw NSError(domain: "User", code: 500) }
                
                mockUser = user
        }
        
        func fetchUser(userId: String) async throws -> User? {
                defer { onFetchUser?() } // 🛡️
                
                if shouldReturnError { throw NSError(domain: "User", code: 404) }
                
                return mockUser
        }
        
        func uploadProfileImage(data: Data) async throws -> String {
                defer { onUploadImage?() } // 🛡️
                
                // J'ai ajouté la simulation d'erreur ici aussi
                if shouldReturnError { throw NSError(domain: "User", code: 500) }
                
                return "https://mock-storage.com/avatar.jpg"
        }
}
