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
        
        //MARK: 
        nonisolated(unsafe)  var mockUser: User?
        nonisolated(unsafe) var shouldReturnError = false
        
        //MARK:
        nonisolated  func saveUser(_ user: User) async throws {
                if shouldReturnError { throw NSError(domain: "User", code: 500) }
                self.mockUser = user
        }
        
        nonisolated func fetchUser(userId: String) async throws -> User? {
                if shouldReturnError { throw NSError(domain: "User", code: 404) }
                return mockUser
        }
        
        nonisolated func uploadProfileImage(data: Data) async throws -> String {
                return "https://mock-storage.com/avatar.jpg"
        }
}
