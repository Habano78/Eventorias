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
        
        @Test
        func initLoadsUserIfSignedIn() async throws {
                let preMockAuth = MockAuthService()
                preMockAuth.mockUserId = "existing_uid"
                
                let preMockUser = MockUserService()
                preMockUser.mockUser = User(fireBaseUserId: "existing_uid", email: "old@test.com", name: "Old User")
                
                await confirmation("Init loads session") { confirm in
                        // ✅ CORRECTION : On utilise l'instance 'preMockUser', pas la classe
                        preMockUser.onFetchUser = { confirm() }
                        
                        _ = AuthViewModel(authService: preMockAuth, userService: preMockUser)
                        
                        // On laisse un micro-délai pour que la Task de l'init démarre
                        try? await Task.sleep(nanoseconds: 100_000_000)
                }
                
                await Task.yield()
                #expect(preMockAuth.mockUserId == "existing_uid")
        }
        
        @Test
        func signInSuccess() async throws {
                mockUserService.mockUser = User(fireBaseUserId: "test_user_id", email: "login@test.com", name: "Logged User")
                
                await confirmation("SignIn completes") { confirm in
                        mockAuthService.onSignIn = { confirm() }
                        await viewModel.signIn(email: "login@test.com", password: "password")
                }
                
                await Task.yield()
                #expect(viewModel.currentUser?.name == "Logged User")
                #expect(viewModel.errorMessage == nil)
        }
        
        @Test
        func signInFailure() async throws {
                mockAuthService.shouldReturnError = true
                
                await confirmation("SignIn fails") { confirm in
                        mockAuthService.onSignIn = { confirm() }
                        await viewModel.signIn(email: "fail@test.com", password: "wrong")
                }
                
                await Task.yield()
                #expect(viewModel.currentUser == nil)
                #expect(viewModel.errorMessage != nil)
                #expect(viewModel.errorMessage!.contains("Erreur connexion"))
        }
        
        @Test
        func signUpFullProcess() async throws {
                let email = "new@test.com"
                
                await confirmation("SignUp completes") { confirm in
                        mockAuthService.onSignUp = { confirm() }
                        await viewModel.signUp(email: email, password: "123")
                }
                
                await Task.yield()
                
                let savedUser = try #require(mockUserService.mockUser)
                #expect(savedUser.email == email)
                #expect(savedUser.fireBaseUserId == "new_user_id")
                #expect(viewModel.currentUser != nil)
        }
        
        @Test
        func signUpFailure() async throws {
                mockAuthService.shouldReturnError = true
                
                await confirmation("SignUp fails") { confirm in
                        mockAuthService.onSignUp = { confirm() }
                        await viewModel.signUp(email: "fail@test.com", password: "123")
                }
                
                await Task.yield()
                #expect(viewModel.currentUser == nil)
                #expect(viewModel.errorMessage != nil)
        }
        
        @Test
        func updateProfileSuccess() async throws {
                let initialUser = User(fireBaseUserId: "uid_123", email: "test@test.com", name: "Ancien")
                mockUserService.mockUser = initialUser
                viewModel.currentUser = initialUser
                
                await confirmation("Update profile completes") { confirm in
                        mockUserService.onSaveUser = { confirm() }
                        await viewModel.updateProfile(name: "Nouveau", isNotifEnabled: true, image: nil)
                }
                
                await Task.yield()
                #expect(mockUserService.mockUser?.name == "Nouveau")
                #expect(viewModel.currentUser?.name == "Nouveau")
        }
        
        @Test
        func updateProfileWithImage() async throws {
                let user = User(fireBaseUserId: "u1", email: "a@a.com", name: "Bob")
                mockUserService.mockUser = user
                viewModel.currentUser = user
                
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
                let fakeImage = renderer.image { ctx in
                        UIColor.red.setFill()
                        ctx.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
                }
                
                await confirmation("Upload and Save completes") { confirm in
                        mockUserService.onSaveUser = { confirm() }
                        await viewModel.updateProfile(name: "Bob avec Photo", isNotifEnabled: true, image: fakeImage)
                }
                
                await Task.yield()
                #expect(mockUserService.mockUser?.profileImageURL == "https://mock-storage.com/avatar.jpg")
        }
        
        @Test func updateProfileFailure() async throws {
                
                viewModel.currentUser = User(
                        fireBaseUserId: "test_id",
                        email: "test@example.com",
                        name: "Ancien Nom",
                        profileImageURL: nil,
                        isNotificationsEnabled: false
                )
                
                mockUserService.shouldReturnError = true
                
                await confirmation("Le service saveUser doit être appelé 1 fois", expectedCount: 1) { confirm in
                        
                        mockUserService.onSaveUser = {
                                confirm()
                        }
                        
                        await viewModel.updateProfile(name: "Nouveau Nom", isNotifEnabled: true, image: nil)
                }
                let message = try #require(viewModel.errorMessage)
                #expect(message.contains("Erreur de sauvegarde"))
        }
}
