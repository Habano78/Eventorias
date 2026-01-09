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
        
        nonisolated(unsafe) var mockUserId: String? = "test_user_id"
        nonisolated(unsafe) var shouldReturnError = false
        
        
        nonisolated var currentUserId: String? {
                return mockUserId
        }
        
        nonisolated func signIn(email: String, password: String) async throws -> String {
                if shouldReturnError { throw NSError(domain: "Auth", code: 401) }
                return mockUserId!
        }
        
        nonisolated func signUp(email: String, password: String) async throws -> String {
                if shouldReturnError { throw NSError(domain: "Auth", code: 500) }
                return "new_user_id"
        }
        
        nonisolated func signOut() throws {
                if shouldReturnError { throw NSError(domain: "Auth", code: 500) }
        }
}
