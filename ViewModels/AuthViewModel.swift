//
//  AuthViewModel.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

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
        var userSession: FirebaseAuth.User?
        var errorMessage: String?
        
        //MARK: init
        init() {
                self.userSession = Auth.auth().currentUser
                startListening() 
        }
        
        //MARK: Methodes
        
        func startListening() {
                Auth.auth().addStateDidChangeListener { [weak self] _, user in
                       
                        self?.userSession = user
                }
        }
        
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
