//
//  AuthViewModel.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import Foundation
import FirebaseAuth
import Observation


@Observable
class AuthViewModel {
        
        //MARK: Properties
    var userSession: FirebaseAuth.User? /// variable contient l'utilisateur connecté (ou nil si personne)
    var errorMessage: String?
    
        //MARK: init
    init() {
        self.userSession = Auth.auth().currentUser///on vérifie si quelqu'un est déjà connecté
    }
    
        //MARK: Methodes
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Erreur : \(error.localizedDescription)"
                return
            }
            // Succès : on met à jour la session
            self.userSession = result?.user
            self.errorMessage = nil
        }
    }
    
        
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = "Erreur création : \(error.localizedDescription)"
                return
            }
            self.userSession = result?.user
            self.errorMessage = nil
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
        } catch {
            self.errorMessage = "Erreur déconnexion"
        }
    }
}
