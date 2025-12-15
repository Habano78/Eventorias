//
//  AuthentificationView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

import SwiftUI

struct AuthentificationView: View {
    
        //MARK: dependencies
    var viewModel: AuthViewModel
    
    //MARK: properties
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true // true = Connexion, false = Inscription
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text(isLoginMode ? "Connexion" : "Inscription")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Email
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            
            // Mot de passe
            SecureField("Mot de passe", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            
            //  erreurs éventuelles
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            // Bouton Principal
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
            
            // Bouton de bascule
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
    AuthentificationView(viewModel: AuthViewModel())
}
