//
//  AuthViewModel.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation
import FirebaseAuth
import Observation
import SwiftUI

// MARK: Classe Enveloppe
private final class AuthListenerToken: @unchecked Sendable {
        var handle: AuthStateDidChangeListenerHandle?
        
        deinit {
                if let handle {
                        Auth.auth().removeStateDidChangeListener(handle)
                }
        }
}

// MARK: ViewModel
@MainActor
@Observable
class AuthViewModel {
        
        // MARK: Instances
        private let service: EventServiceProtocol
        
        // MARK: Properties
        var userSession: FirebaseAuth.User?
        var currentUser: User?
        var errorMessage: String?
        var isLoading: Bool = false
        
        private let listenerToken = AuthListenerToken()
        
        // MARK: init
        init(service: EventServiceProtocol) {
                self.service = service
                self.userSession = Auth.auth().currentUser
                startListening()
        }
        
        // MARK: - Gestion de l'écoute
        
        func startListening() {
                listenerToken.handle = Auth.auth().addStateDidChangeListener { [weak self] _, fireBaseUser in
                        
                        Task { @MainActor [weak self] in
                                self?.userSession = fireBaseUser
                                
                                if let uid = fireBaseUser?.uid {
                                        await self?.fetchUser(fireBaseUserId: uid)
                                } else {
                                        self?.currentUser = nil
                                }
                        }
                }
        }
        
        // MARK: - Méthodes Profil
        
        func fetchUser(fireBaseUserId: String) async {
                self.isLoading = true
                do {
                        self.currentUser = try await service.fetchUser(userId: fireBaseUserId)
                } catch {
                        print("Erreur chargement user: \(error.localizedDescription)")
                }
                self.isLoading = false
        }
        
        
        func updateProfile(name: String, isNotifEnabled: Bool, image: UIImage?) {
                
                guard let currentUid = currentUser?.fireBaseUserId, let email = currentUser?.email else { return }
                
                self.isLoading = true
                self.errorMessage = nil
                
                Task {
                        do {
                                var imageURL: String? = self.currentUser?.profileImageURL
                                
                                if let image = image, let imageData = image.jpegData(compressionQuality: 0.5) {
                                        imageURL = try await service.uploadImage(data: imageData)
                                }
                                
                                let updatedUser = User(
                                        fireBaseUserId: currentUid,
                                        email: email,
                                        name: name,
                                        profileImageURL: imageURL,
                                        isNotificationsEnabled: isNotifEnabled
                                )
                                
                                try await service.saveUser(updatedUser)
                                self.currentUser = updatedUser
                                
                        } catch {
                                self.errorMessage = "Erreur sauvegarde : \(error.localizedDescription)"
                        }
                        self.isLoading = false
                }
        }
        
        // MARK: - Méthodes Authentification
        
        func signIn(email: String, password: String) {
                self.isLoading = true
                self.errorMessage = nil
                
                Task {
                        do {
                                let uid = try await service.signIn(email: email, password: password)
                                await self.fetchUser(fireBaseUserId: uid)
                        } catch {
                                self.errorMessage = "Erreur connexion : \(error.localizedDescription)"
                        }
                        self.isLoading = false
                }
        }
        
        func signUp(email: String, password: String) {
                self.isLoading = true
                self.errorMessage = nil
                
                Task {
                        do {
                                let uid = try await service.signUp(email: email, password: password)
                                
                                let newUser = User(
                                        fireBaseUserId: uid,
                                        email: email,
                                        name: "Nouvel Utilisateur",
                                        profileImageURL: nil,
                                        isNotificationsEnabled: false
                                )
                                
                                try await service.saveUser(newUser)
                                self.currentUser = newUser
                                
                        } catch {
                                self.errorMessage = "Erreur inscription : \(error.localizedDescription)"
                        }
                        self.isLoading = false
                }
        }
        
        func signOut() {
                do {
                        try service.signOut()
                        self.currentUser = nil
                        self.userSession = nil
                } catch {
                        self.errorMessage = "Erreur déconnexion"
                }
        }
        
}
