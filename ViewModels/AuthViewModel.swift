//
//  AuthViewModel.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation
import FirebaseAuth
import Observation
import SwiftUI // Pour UIImage

@Observable
class AuthViewModel {
        
        //MARK: instances
        private let service = Service()
        
        // MARK: Properties
        var userSession: FirebaseAuth.User?
        var currentUser: User?
        var errorMessage: String?
        var isLoading: Bool = false
        
        private var authStateHandler: AuthStateDidChangeListenerHandle? /// écoute de firebase
        
        // MARK: init
        init() {
                self.userSession = Auth.auth().currentUser
                if let uid = userSession?.uid {
                        fetchUser(fireBaseUserId: uid)
                }
                startListening()
        }
        
        // MARK: Méthodes d'Écoute et Nettoyage
        func startListening() {
                authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, fireBaseUser in
                        self?.userSession = fireBaseUser
                        
                        if let uid = fireBaseUser?.uid {
                                
                                self?.fetchUser(fireBaseUserId: uid)
                        } else {
                               
                                self?.currentUser = nil
                        }
                }
        }
        
        deinit {
                if let handler = authStateHandler {
                        Auth.auth().removeStateDidChangeListener(handler)
                }
        }
        
        // MARK: - Méthodes Profil (Firestore)
        
        func fetchUser(fireBaseUserId: String) {
                self.isLoading = true
                
                service.fetchUser(userId: fireBaseUserId) { [weak self] user in
                        self?.currentUser = user
                        self?.isLoading = false
                }
        }
        
        /// Mettre à jour le profil
        func updateProfile(name: String, isNotifEnabled: Bool, image: UIImage?) {
                guard let currentUid = userSession?.uid, let email = userSession?.email else { return }
                
                self.isLoading = true
                
                func saveUserData(imageURL: String?) {
                        let finalImageURL = imageURL ?? self.currentUser?.profileImageURL
                        
                        let updatedUser = User(
                                fireBaseUserId: currentUid,
                                email: email,
                                name: name,
                                profileImageURL: finalImageURL,
                                isNotificationsEnabled: isNotifEnabled
                        )
                        
                        service.saveUser(updatedUser) { success in
                                if success {
                                        self.currentUser = updatedUser
                                } else {
                                        self.errorMessage = "Erreur lors de la sauvegarde"
                                }
                                self.isLoading = false
                        }
                }
                
                if let image = image, let imageData = image.jpegData(compressionQuality: 0.5) {
                        service.uploadImage(data: imageData) { url in
                                saveUserData(imageURL: url)
                        }
                } else {
                        saveUserData(imageURL: nil)
                }
        }
        
        // MARK: - Méthodes Authentification
        
        func signIn(email: String, password: String) {
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                        if let error = error {
                                self.errorMessage = "Erreur : \(error.localizedDescription)"
                                return
                        }
                        self.errorMessage = nil
                }
        }
        
        func signUp(email: String, password: String) {
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                        if let error = error {
                                self.errorMessage = "Erreur création : \(error.localizedDescription)"
                                return
                        }
                        
                        /// Création du document utilisateur initial dans Firestore
                        if let uid = result?.user.uid {
                                
                                let newUser = User(
                                        fireBaseUserId: uid,
                                        email: email,
                                        name: "Nouvel Utilisateur"
                                )
                                
                                self.service.saveUser(newUser) { _ in }
                        }
                        
                        self.errorMessage = nil
                }
        }
        
        func signOut() {
                do {
                        try Auth.auth().signOut()
                } catch {
                        self.errorMessage = "Erreur déconnexion"
                }
        }
}
