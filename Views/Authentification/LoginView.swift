//
//  AuthentificationView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct LoginView: View {
        
        //MARK: dependencies
        @Environment(AuthViewModel.self) var authViewModel
        
        //MARK: properties
        @State private var email = ""
        @State private var password = ""
        @State private var isLoginMode = true
        
        //MARK: body
        var body: some View {
                ZStack {
                        
                        Color.black.ignoresSafeArea()
                        VStack(spacing: 20) {
                                /// Titre
                                Text(isLoginMode ? "Connexion" : "Inscription")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .accessibilityAddTraits(.isHeader)
                                
                                /// Email
                                TextField("Email", text: $email)
                                        .disabled(authViewModel.isLoading)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .padding()
                                        .background(Color(white: 0.15))
                                        .foregroundStyle(.white)
                                        .cornerRadius(10)
                                        .accessibilityLabel("Adresse email")
                                        .accessibilityInputLabels(["Email"])
                                
                                /// Mot de passe
                                SecureField("Mot de passe", text: $password)
                                        .disabled(authViewModel.isLoading)
                                        .padding()
                                        .background(Color(white: 0.15))
                                        .foregroundStyle(.white)
                                        .cornerRadius(10)
                                        .accessibilityLabel("Mot de passe")
                                
                                if let errorMessage = authViewModel.errorMessage {
                                        Text(errorMessage)
                                                .foregroundStyle(.red)
                                                .font(.caption)
                                                .accessibilityLabel("Erreur : \(errorMessage)")
                                }
                                
                                Button {
                                        Task {
                                                if isLoginMode {
                                                        await authViewModel.signIn(email: email, password: password)
                                                } else {
                                                        await authViewModel.signUp(email: email, password: password)
                                                }
                                        }
                                } label: {
                                        Text(isLoginMode ? "Se connecter" : "Créer un compte")
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.red)
                                                .foregroundStyle(.white)
                                                .cornerRadius(10)
                                }
                                .accessibilityLabel(isLoginMode ? "Se connecter" : "S'inscrire")
                                .disabled(authViewModel.isLoading)
                                .accessibilityHint("Valide le formulaire")
                                
                                
                                Button {
                                        withAnimation {
                                                isLoginMode.toggle()
                                        }
                                } label: {
                                        Text(isLoginMode ? "Pas encore de compte ? S'inscrire" : "Déjà un compte ? Se connecter")
                                                .foregroundStyle(.gray)
                                }
                                .accessibilityLabel(isLoginMode ? "Basculer vers l'inscription" : "Basculer vers la connexion")
                                .accessibilityHint("Change le mode du formulaire")
                        }
                        .padding()
                }
                .preferredColorScheme(.dark)
        }
}
