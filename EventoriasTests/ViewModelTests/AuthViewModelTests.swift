//
//  AuthViewModelTests.swift
//  EventoriasTests
//
//  Created by Perez William on 08/01/2026.
//

import Testing
import Foundation
import FirebaseCore
import UIKit
@testable import Eventorias

@MainActor
struct AuthViewModelTests {
        
        let viewModel: AuthViewModel
        let mockAuthService: MockAuthService
        let mockUserService: MockUserService
        
        init() {
                if FirebaseApp.app() == nil { FirebaseApp.configure() }
                
                self.mockAuthService = MockAuthService()
                self.mockUserService = MockUserService()
                
                self.viewModel = AuthViewModel(
                        authService: mockAuthService,
                        userService: mockUserService
                )
        }
        
        // MARK: Tests Init & Session
        
        @Test("Init: Charge l'utilisateur si déjà connecté")
        func initLoadsUserIfSignedIn() async throws {
                // Given
                let preMockAuth = MockAuthService()
                preMockAuth.mockUserId = "existing_uid"
                
                let preMockUser = MockUserService()
                preMockUser.mockUser = User(fireBaseUserId: "existing_uid", email: "old@test.com", name: "Old User")
                
                // When
                let vm = AuthViewModel(authService: preMockAuth, userService: preMockUser)
                try await Task.sleep(nanoseconds: 100_000_000)
                
                // Then
                #expect(vm.currentUser?.name == "Old User")
                #expect(vm.isUserSignedIn == true)
        }
        
        // MARK: Tests Connexion (SignIn)
        
        @Test("Connexion réussie")
        func signInSuccess() async throws {
                // Given
                mockUserService.mockUser = User(fireBaseUserId: "test_user_id", email: "login@test.com", name: "Logged User")
                
                // When
                viewModel.signIn(email: "login@test.com", password: "password")
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(viewModel.currentUser?.name == "Logged User")
                #expect(viewModel.errorMessage == nil)
        }
        
        @Test("Echec connexion (Mauvais mot de passe)")
        func signInFailure() async throws {
                // Given
                mockAuthService.shouldReturnError = true
                
                // When
                viewModel.signIn(email: "fail@test.com", password: "wrong")
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(viewModel.currentUser == nil)
                #expect(viewModel.errorMessage != nil)
                #expect(viewModel.errorMessage!.contains("Erreur connexion"))
        }
        
        // MARK: Tests Inscription (SignUp)
        
        @Test("Inscription complète (Happy Path)")
        func signUpFullProcess() async throws {
                // Given
                let email = "new@test.com"
                
                // When
                viewModel.signUp(email: email, password: "123")
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                let savedUser = try #require(mockUserService.mockUser)
                #expect(savedUser.email == email)
                #expect(savedUser.fireBaseUserId == "new_user_id")
                #expect(viewModel.currentUser != nil)
        }
        
        @Test("Echec Inscription (Service Auth Down)")
        func signUpFailure() async throws {
                // Given
                mockAuthService.shouldReturnError = true
                
                // When
                viewModel.signUp(email: "fail@test.com", password: "123")
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(viewModel.currentUser == nil)
                #expect(viewModel.errorMessage != nil)
        }
        
        // MARK: Tests SignOut
        
        @Test("Déconnexion réussie")
        func signOutSuccess() {
                // Given
                let user = User(fireBaseUserId: "uid", email: "e", name: "n")
                viewModel.currentUser = user
                
                // When
                viewModel.signOut()
                
                // Then
                #expect(viewModel.currentUser == nil)
        }
        
        @Test("Echec Déconnexion (SignOut Catch)")
        func signOutFailure() {
                // Given
                mockAuthService.shouldReturnError = true
                
                // When
                viewModel.signOut()
                
                // Then
                #expect(viewModel.errorMessage == "Erreur déconnexion")
        }
        
        // MARK: Tests Profil
        
        @Test("Mise à jour profil réussie")
        func updateProfileSuccess() async throws {
                // Given
                let initialUser = User(fireBaseUserId: "uid_123", email: "test@test.com", name: "Ancien")
                mockUserService.mockUser = initialUser
                viewModel.currentUser = initialUser
                
                // When
                viewModel.updateProfile(name: "Nouveau", isNotifEnabled: true, image: nil)
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(mockUserService.mockUser?.name == "Nouveau")
                #expect(viewModel.currentUser?.name == "Nouveau")
        }
        
        @Test("Mise à jour profil AVEC Image (Test Upload)")
        func updateProfileWithImage() async throws {
                // Given
                let user = User(fireBaseUserId: "u1", email: "a@a.com", name: "Bob")
                mockUserService.mockUser = user
                viewModel.currentUser = user
                
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
                let fakeImage = renderer.image { ctx in
                        UIColor.red.setFill()
                        ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
                }
                
                // When
                viewModel.updateProfile(name: "Bob avec Photo", isNotifEnabled: true, image: fakeImage)
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(mockUserService.mockUser?.profileImageURL == "https://mock-storage.com/avatar.jpg")
                #expect(viewModel.currentUser?.profileImageURL == "https://mock-storage.com/avatar.jpg")
        }
        
        @Test("Echec mise à jour profil")
        func updateProfileFailure() async throws {
                // Given
                let initialUser = User(fireBaseUserId: "uid_123", email: "test@test.com", name: "Ancien")
                viewModel.currentUser = initialUser
                mockUserService.shouldReturnError = true
                
                // When
                viewModel.updateProfile(name: "Impossible", isNotifEnabled: true, image: nil)
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // Then
                #expect(viewModel.errorMessage != nil)
                #expect(viewModel.errorMessage!.contains("Erreur de sauvegarde"))
        }
        
        @Test("Echec Chargement User (FetchUser Catch)")
        func fetchUserFailure() async throws {
                // Given
                mockUserService.shouldReturnError = true
                
                // When
                await viewModel.fetchUser(fireBaseUserId: "uid_bad")
                
                // Then
                #expect(viewModel.errorMessage == "Impossible de charger le profil.")
        }
        
        @Test("Tentative modification profil sans être connecté (Guard Check)")
        func updateProfileWithoutUser() async throws {
                // Given
                viewModel.currentUser = nil
                
                // When
                viewModel.updateProfile(name: "Hacker", isNotifEnabled: true, image: nil)
                
                // Then
                #expect(viewModel.isLoading == false)
                #expect(viewModel.errorMessage == nil)
        }
}
