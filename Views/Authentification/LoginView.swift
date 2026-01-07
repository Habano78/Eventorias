//
//  AuthentificationView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

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
                                
                                /// Email
                                TextField("Email", text: $email)
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                        .padding()
                                        .background(Color(white: 0.15))
                                        .foregroundStyle(.white)
                                        .cornerRadius(10)
                                
                                /// Mot de passe
                                SecureField("Mot de passe", text: $password)
                                        .padding()
                                        .background(Color(white: 0.15))
                                        .foregroundStyle(.white)
                                        .cornerRadius(10)
                                
                                if let errorMessage = authViewModel.errorMessage {
                                        Text(errorMessage)
                                                .foregroundStyle(.red)
                                                .font(.caption)
                                }
                                
                                Button {
                                        if isLoginMode {
                                                authViewModel.signIn(email: email, password: password)
                                        } else {
                                                authViewModel.signUp(email: email, password: password)
                                        }
                                } label: {
                                        Text(isLoginMode ? "Se connecter" : "Créer un compte")
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.red)
                                                .foregroundStyle(.white)
                                                .cornerRadius(10)
                                }
                                
                                Button {
                                        withAnimation {
                                                isLoginMode.toggle()
                                        }
                                } label: {
                                        Text(isLoginMode ? "Pas encore de compte ? S'inscrire" : "Déjà un compte ? Se connecter")
                                                .foregroundStyle(.gray)
                                }
                        }
                        .padding()
                }
                .preferredColorScheme(.dark)
        }
}
