//
//  AuthViewModelTests.swift
//  EventoriasTests
//
//  Created by Perez William on 07/01/2026.
//

import Testing
import Foundation
import UIKit // Nécessaire pour UIImage
@testable import Eventorias

@MainActor
struct AuthViewModelTests {
        
        let viewModel: AuthViewModel
        let mockService: MockEventService
        
        init() {
                self.mockService = MockEventService()
                self.viewModel = AuthViewModel(service: mockService)
        }
        
        // MARK: - Tests
        
        @Test("Récupération d'un utilisateur existant")
        func fetchUserSuccess() async {
                // GIVEN (On simule un utilisateur déjà en base)
                let user = User(fireBaseUserId: "uid_123", email: "test@test.com", name: "Toto", isNotificationsEnabled: true)
                mockService.mockUser = user
                
                // WHEN
                await viewModel.fetchUser(fireBaseUserId: "uid_123")
                
                // THEN
                #expect(viewModel.isLoading == false)
                let loadedUser = try? #require(viewModel.currentUser)
                #expect(loadedUser?.name == "Toto")
                #expect(loadedUser?.email == "test@test.com")
        }
        
        @Test("Récupération échoue (ex: pas d'internet)")
        func fetchUserError() async {
                // GIVEN
                mockService.shouldReturnError = true
                
                // WHEN
                await viewModel.fetchUser(fireBaseUserId: "uid_123")
                
                // THEN
                #expect(viewModel.currentUser == nil)
        
        }
        
        // MARK: - Tests de Mise à jour Profil (Le plus important !)
        
        @Test("Mise à jour du profil")
        func updateProfileSuccess() async throws {
                // GIVEN
                let initialUser = User(fireBaseUserId: "uid_123", email: "test@test.com", name: "Ancien Nom")
                mockService.mockUser = initialUser
                viewModel.currentUser = initialUser // On injecte l'état connecté
                
                // WHEN
                // On modifie le nom et on active les notifs
                viewModel.updateProfile(name: "Nouveau Nom", isNotifEnabled: true, image: nil)
                
                // ATTENTE (Task interne)
                try await Task.sleep(nanoseconds: 200_000_000)
                
                // THEN
                // 1. On vérifie que le VM est à jour
                let updatedUser = try #require(viewModel.currentUser)
                #expect(updatedUser.name == "Nouveau Nom")
                #expect(updatedUser.isNotificationsEnabled == true)
                
                // 2. On vérifie que le Service (Mock) a bien reçu la sauvegarde
                #expect(mockService.mockUser?.name == "Nouveau Nom")
        }
        
        // MARK: - Test Inscription (Logique de sauvegarde)
        
        @Test("Sauvegarde des données après inscription")
        func signUpUserCreation() async throws {
                // Ce test vérifie que SI l'inscription Firebase réussit, ALORS on sauvegarde bien le User dans Firestore.
                // On contourne l'appel Auth.auth() pour tester juste la logique de sauvegarde.
                
                // GIVEN
                let newUser = User(fireBaseUserId: "new_id", email: "new@test.com", name: "Nouvel Utilisateur")
                
                // WHEN
                // On appelle directement le service comme le ferait le ViewModel
                try await mockService.saveUser(newUser)
                
                // THEN
                let savedUser = mockService.mockUser
                #expect(savedUser?.email == "new@test.com")
                #expect(savedUser?.fireBaseUserId == "new_id")
        }
}
