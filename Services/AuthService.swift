//
//  AuthService.swift
//  Eventorias
//
//  Created by Perez William on 07/01/2026.
//

import Foundation
import FirebaseAuth

// MARK: - Protocol
protocol AuthServiceProtocol: Sendable {
        var currentUserId: String? { get }
        func signIn(email: String, password: String) async throws -> String
        func signUp(email: String, password: String) async throws -> String
        func signOut() throws
}

// MARK: Implementation
final class AuthService: AuthServiceProtocol {
        
        var currentUserId: String? {
                return Auth.auth().currentUser?.uid
        }
        
        func signIn(email: String, password: String) async throws -> String {
                let result = try await Auth.auth().signIn(withEmail: email, password: password)
                return result.user.uid
        }
        
        func signUp(email: String, password: String) async throws -> String {
                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                return result.user.uid
        }
        
        func signOut() throws {
                try Auth.auth().signOut()
        }
}


// Auht gère uniquement émail, mot de passe, jetons de session (tokens) et l'UID unique.
