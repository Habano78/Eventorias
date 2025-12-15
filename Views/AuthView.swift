//
//  LogInView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

import SwiftUI

struct AuthentificationView: View {
    // 1. On reçoit le ViewModel (le cerveau) pour lui donner des ordres
    var viewModel: AuthViewModel
    
    // 2. Variables locales pour stocker ce que l'utilisateur tape
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true // true = Connexion, false = Inscription
    
    var body: some View {
        VStack(spacing: 20) {
            
            // Titre dynamique
            Text(isLoginMode ? "Connexion" : "Inscription")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Champ Email
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none) // Important pour les emails !
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            
            // Champ Mot de passe
            SecureField("Mot de passe", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            
            // Affichage des erreurs éventuelles (rouge)
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            // Bouton Principal (Action)
            Button {
                if isLoginMode {
                    viewModel.signIn(email: email, password: password)
                } else {
                    viewModel.signUp(email: email, password: password)
                }
            } label: {
                Text(isLoginMode ? "Se connecter" : "Créer un compte")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
            }
            
            // Bouton de bascule (Switch mode)
            Button {
                withAnimation {
                    isLoginMode.toggle()
                }
            } label: {
                Text(isLoginMode ? "Pas encore de compte ? S'inscrire" : "Déjà un compte ? Se connecter")
                    .foregroundStyle(.blue)
            }
        }
        .padding()
    }
}

#Preview {
    // Pour la prévisualisation dans Xcode, on injecte un ViewModel vide
    AuthentificationView(viewModel: AuthViewModel())
}
