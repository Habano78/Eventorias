//
//  MockAuthService.swift
//  EventoriasTests
//
//  Created by Perez William on 08/01/2026.
//

import Foundation
@testable import Eventorias

@MainActor
final class MockAuthService: AuthServiceProtocol {
        
        // MARK: Configuration
        var mockUserId: String? = "test_user_id"
        var shouldReturnError = false
        
        // MARK: Hooks
        var onSignIn: (() -> Void)?
        var onSignUp: (() -> Void)?
        var onSignOut: (() -> Void)?
        
        
        // MARK: Implementation
        var currentUserId: String? {
                return mockUserId
        }
        
        func signIn(email: String, password: String) async throws -> String {
                defer { onSignIn?() }
                if shouldReturnError { throw NSError(domain: "Auth", code: 401) }
                
                return mockUserId ?? "default_id"
        }
        
        func signUp(email: String, password: String) async throws -> String {
                defer { onSignUp?() }
                if shouldReturnError { throw NSError(domain: "Auth", code: 500) }
                
                return "new_user_id"
        }
        
        func signOut() throws {
                defer { onSignOut?() }
                if shouldReturnError { throw NSError(domain: "Auth", code: 500) }
        }
}
