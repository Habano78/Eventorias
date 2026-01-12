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
        
        // MARK: - Properties
        let viewModel: AuthViewModel
        let mockAuthService: MockAuthService
        let mockUserService: MockUserService
        
        // MARK: Setup
        init() {
                if FirebaseApp.app() == nil { FirebaseApp.configure() }
                
                self.mockAuthService = MockAuthService()
                self.mockUserService = MockUserService()
                
                self.viewModel = AuthViewModel(
                        authService: mockAuthService,
                        userService: mockUserService
                )
        }
        
        // MARK: Init + Session
        
        @Test("Init: Charge l'utilisateur s'il est déjà connecté")
        func initLoadsUserIfSignedIn() async {
                // Given
                let auth = MockAuthService()
                auth.mockUserId = "uid"
                
                let userService = MockUserService()
                userService.mockUser = User(fireBaseUserId: "uid", email: "a@a.com", name: "User")
                
                // When
                await confirmation { confirm in
                        userService.onFetchUser = { confirm() }
                        
                        _ = AuthViewModel(authService: auth, userService: userService)
                        
                        try? await Task.sleep(nanoseconds: 100_000_000)
                }
                
        }
        
        @Test("isUserSignedIn: Renvoie true si un utilisateur est connecté")
        func isUserSignedIn_true() async {
                // Given
                mockAuthService.mockUserId = "some_uid"
                
                // When & Then
                #expect(viewModel.isUserSignedIn == true)
        }
        
        @Test("isUserSignedIn: Renvoie false si aucun utilisateur n'est connecté")
        func isUserSignedIn_false() async {
                // Given
                mockAuthService.mockUserId = nil
                
                // When & Then
                #expect(viewModel.isUserSignedIn == false)
        }
        
        // MARK: SignIn
        
        @Test("SignIn: Connecte l'utilisateur avec succès")
        func signInSuccess() async {
                // Given
                mockUserService.mockUser = User(fireBaseUserId: "uid", email: "login@test.com", name: "Logged")
                
                // When
                await confirmation { confirm in
                        mockAuthService.onSignIn = { confirm() }
                        await viewModel.signIn(email: "login@test.com", password: "123")
                }
                
                // Then
                #expect(viewModel.currentUser?.name == "Logged")
        }
        
        @Test("SignIn: Échoue avec une erreur")
        func signInFailure() async {
                // Given
                mockAuthService.shouldReturnError = true
                
                // When
                await confirmation { confirm in
                        mockAuthService.onSignIn = { confirm() }
                        await viewModel.signIn(email: "fail", password: "fail")
                }
                
                // Then
                #expect(viewModel.currentUser == nil)
                #expect(viewModel.errorMessage != nil)
        }
        
        // MARK: SignUp
        
        @Test("SignUp: Inscrit et sauvegarde l'utilisateur")
        func signUpSuccess() async {
                // Given
                // (Pas de setup spécifique requis, le mock renvoie des valeurs par défaut)
                
                // When
                await confirmation { confirm in
                        mockAuthService.onSignUp = { confirm() }
                        await viewModel.signUp(email: "new@test.com", password: "123")
                }
                
                // Then
                #expect(viewModel.currentUser?.email == "new@test.com")
                #expect(viewModel.currentUser?.name == "Nouvel Utilisateur")
        }
        
        @Test("SignUp: Échoue si le service Auth plante")
        func signUpFailure() async {
                // Given
                mockAuthService.shouldReturnError = true
                
                // When
                await confirmation { confirm in
                        mockAuthService.onSignUp = { confirm() }
                        await viewModel.signUp(email: "fail@test.com", password: "123")
                }
                
                // Then
                #expect(viewModel.currentUser == nil)
                #expect(viewModel.errorMessage != nil)
        }
        
        // MARK: SignOut
        
        @Test("SignOut: Déconnecte l'utilisateur")
        func signOutSuccess() {
                // Given
                viewModel.currentUser = User(fireBaseUserId: "u1", email: "a@a.com", name: "Bob")
                
                // When
                viewModel.signOut()
                
                // Then
                #expect(viewModel.currentUser == nil)
        }
        
        @Test("SignOut: Gère l'erreur")
        func signOutFailure() {
                // Given
                mockAuthService.shouldReturnError = true
                
                // When
                viewModel.signOut()
                
                // Then
                #expect(viewModel.errorMessage == "Erreur déconnexion")
        }
        
        // MARK: Profil (Update & Fetch)
        
        @Test("FetchUser: Gère l'erreur de chargement")
        func fetchUserFailure() async {
                // Given
                mockUserService.shouldReturnError = true
                
                // When
                await viewModel.fetchUser(fireBaseUserId: "bad_uid")
                
                // Then
                #expect(viewModel.errorMessage == "Impossible de charger le profil.")
        }
        
        @Test("UpdateProfile: Met à jour le profil avec succès")
        func updateProfileSuccess() async {
                // Given
                let user = User(fireBaseUserId: "u1", email: "a@a.com", name: "Old")
                viewModel.currentUser = user
                mockUserService.mockUser = user
                
                // When
                await confirmation { confirm in
                        mockUserService.onSaveUser = { confirm() }
                        await viewModel.updateProfile(name: "New", isNotifEnabled: true, image: nil)
                }
                
                // Then
                #expect(viewModel.currentUser?.name == "New")
        }
        
        @Test("UpdateProfile: Met à jour AVEC une image")
        func updateProfileWithImage() async {
                // Given
                let user = User(fireBaseUserId: "u1", email: "a@a.com", name: "Bob")
                viewModel.currentUser = user
                mockUserService.mockUser = user
                
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
                let fakeImage = renderer.image { ctx in UIColor.red.setFill(); ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1)) }
                
                // When
                await confirmation { confirm in
                        mockUserService.onSaveUser = { confirm() }
                        await viewModel.updateProfile(name: "Bob Photo", isNotifEnabled: true, image: fakeImage)
                }
                
                // Then
                #expect(viewModel.currentUser?.profileImageURL == "https://mock-storage.com/avatar.jpg")
        }
        
        @Test("UpdateProfile: Gère l'erreur de sauvegarde")
        func updateProfileFailure() async {
                // Given
                let user = User(fireBaseUserId: "u1", email: "a@a.com", name: "Old")
                viewModel.currentUser = user
                mockUserService.shouldReturnError = true
                
                // When
                await confirmation { confirm in
                        mockUserService.onSaveUser = { confirm() }
                        await viewModel.updateProfile(name: "Fail", isNotifEnabled: true, image: nil)
                }
                
                // Then
                #expect(viewModel.errorMessage != nil)
        }
        
        @Test("UpdateProfile: Ne fait rien si aucun utilisateur")
        func updateProfile_withoutUser_doesNothing() async {
                // Given
                viewModel.currentUser = nil
                
                // When
                await viewModel.updateProfile(name: "X", isNotifEnabled: true, image: nil)
                
                // Then
                #expect(viewModel.isLoading == false)
        }
}
