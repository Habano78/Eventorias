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

// MARK: - 1. La Classe Enveloppe (La clé de la solution)
// Cette petite classe gère le "ticket" Firebase hors du MainActor.
// Elle est marquée @unchecked Sendable car les handles Firebase sont thread-safe.
private final class AuthListenerToken: @unchecked Sendable {
        var handle: AuthStateDidChangeListenerHandle?
        
        deinit {
                // C'est ici que le nettoyage se fait automatiquement
                if let handle {
                        Auth.auth().removeStateDidChangeListener(handle)
                }
        }
}

// MARK: - 2. Le ViewModel
@MainActor
@Observable
class AuthViewModel {
        
        // MARK: Instances
        private let service = Service.shared
        
        // MARK: Properties
        var userSession: FirebaseAuth.User?
        var currentUser: User?
        var errorMessage: String?
        var isLoading: Bool = false
        
        // ✅ CORRECTION DÉFINITIVE :
        // On remplace "var authStateHandler" par notre token.
        // "let" est constant, donc autorisé par Swift 6 même dans un MainActor.
        private let listenerToken = AuthListenerToken()
        
        // MARK: init
        init() {
                self.userSession = Auth.auth().currentUser
                startListening()
        }
        
        // ⚠️ Note : Il n'y a PLUS de 'deinit' dans ce ViewModel.
        // C'est le 'listenerToken' qui s'occupera du nettoyage quand le ViewModel sera détruit.
        
        // MARK: - Gestion de l'écoute
        
        func startListening() {
                // On stocke le handle DANS le token
                listenerToken.handle = Auth.auth().addStateDidChangeListener { [weak self] _, fireBaseUser in
                        
                        // On revient sur le MainActor pour mettre à jour l'interface
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
        
        // MARK: - Méthodes Profil (Firestore)
        
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
                guard let currentUid = userSession?.uid, let email = userSession?.email else { return }
                
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
                                self.errorMessage = "Erreur de sauvegarde : \(error.localizedDescription)"
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
                                let _ = try await Auth.auth().signIn(withEmail: email, password: password)
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
                                let result = try await Auth.auth().createUser(withEmail: email, password: password)
                                
                                let newUser = User(
                                        fireBaseUserId: result.user.uid,
                                        email: email,
                                        name: "Nouvel Utilisateur",
                                        profileImageURL: nil,
                                        isNotificationsEnabled: false
                                )
                                
                                try await service.saveUser(newUser)
                        } catch {
                                self.errorMessage = "Erreur inscription : \(error.localizedDescription)"
                        }
                        self.isLoading = false
                }
        }
        
        func signOut() {
                do {
                        try Auth.auth().signOut()
                        self.currentUser = nil
                } catch {
                        self.errorMessage = "Erreur déconnexion"
                }
        }
}
