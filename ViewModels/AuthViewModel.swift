//
//  AuthViewModel.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
class AuthViewModel {
        
        // MARK: - Dépendances
        private let authService: any AuthServiceProtocol
        private let userService: any UserServiceProtocol
        
        // MARK: - Properties
        var currentUser: User?
        var errorMessage: String?
        var isLoading: Bool = false
        
        
        // MARK: Computed property
        var isUserSignedIn: Bool {
                return authService.currentUserId != nil
        }
        
        // MARK: - Init
        init(
                authService: any AuthServiceProtocol,
                userService: any UserServiceProtocol
        ) {
                self.authService = authService
                self.userService = userService
                
                /// Vérification session au démarrage
                if let uid = authService.currentUserId {
                        Task { await fetchUser(fireBaseUserId: uid) }
                }
        }
        
        // MARK: Authentification -Sign In, Sign Up, Sign Out
        
        func signIn(email: String, password: String) async {
                isLoading = true
               errorMessage = nil
                
                do {
                        let uid = try await authService.signIn(email: email, password: password)
                        await fetchUser(fireBaseUserId: uid)
                } catch {
                        errorMessage = "Erreur connexion : \(error.localizedDescription)"
                }
                isLoading = false
        }
        
        func signUp(email: String, password: String) async {
                isLoading = true
                errorMessage = nil
                
                do {
                        let uid = try await authService.signUp(email: email, password: password)
                        
                        let newUser = User(
                                fireBaseUserId: uid,
                                email: email,
                                name: "Nouvel Utilisateur",
                                profileImageURL: nil,
                                isNotificationsEnabled: false
                        )
                        
                        try await userService.saveUser(newUser)
                        currentUser = newUser
                        
                } catch {
                        errorMessage = "Erreur inscription : \(error.localizedDescription)"
                }
                isLoading = false
        }
        
        func signOut() {
                do {
                        try authService.signOut()
                        currentUser = nil
                } catch {
                        errorMessage = "Erreur déconnexion"
                }
        }
        
        // MARK: Profil -Fetch & Update
        
        func fetchUser(fireBaseUserId: String) async {
                isLoading = true
                do {
                        currentUser = try await userService.fetchUser(userId: fireBaseUserId)
                } catch {
                        print("Erreur chargement user: \(error.localizedDescription)")
                        errorMessage = "Impossible de charger le profil."
                }
                isLoading = false
        }
        
        func updateProfile(name: String, isNotifEnabled: Bool, image: UIImage?) async {
                guard let currentUid = currentUser?.fireBaseUserId, let email = currentUser?.email else { return }
                
                isLoading = true
                errorMessage = nil
                
                do {
                        var imageURL: String? = currentUser?.profileImageURL
                        
                        if let image = image, let imageData = image.jpegData(compressionQuality: 0.5) {
                                imageURL = try await userService.uploadProfileImage(data: imageData)
                        }
                        
                        let updatedUser = User(
                                fireBaseUserId: currentUid,
                                email: email,
                                name: name,
                                profileImageURL: imageURL,
                                isNotificationsEnabled: isNotifEnabled
                        )
                        
                        try await userService.saveUser(updatedUser)
                        currentUser = updatedUser
                        
                } catch {
                       errorMessage = "Erreur de sauvegarde : \(error.localizedDescription)"
                }
                isLoading = false
        }
}
