//
//  WelcomeView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct WelcomeView: View {
        
        //MARK: dependence
        @Environment(AuthViewModel.self) var authViewModel
        
        //MARK: body
        var body: some View {
                NavigationStack {
                        ZStack {
                                
                                Color.black.ignoresSafeArea()
                                
                                VStack(spacing: 30) {
                                        Spacer()
                                        
                                        /// Logo/Titre
                                        VStack(spacing: 20) {
                                                
                                                Image("Logo")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 100, height: 100)
                                                
                                                /// Texte
                                                Text("EVENTORIAS")
                                                        .font(.custom("Times New Roman", size: 35))
                                                        .fontWeight(.bold)
                                                        .foregroundStyle(.white)
                                                        .kerning(5)
                                                        .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)
                                        }
                                        
                                        Spacer()
                                        
                                        /// Bouton "Sign in "
                                        NavigationLink(destination: LoginView()) {
                                                HStack {
                                                        Image(systemName: "envelope.fill")
                                                        Text("Sign in with email")
                                                                .fontWeight(.semibold)
                                                }
                                                .foregroundStyle(.white)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 55)
                                                .background(Color.red)
                                                .cornerRadius(10)
                                        }
                                        .padding(.horizontal, 30)
                                        .padding(.bottom, 200)
                                }
                        }
                }
                .preferredColorScheme(.dark)
        }
}
