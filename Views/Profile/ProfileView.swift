//
//  ProfileView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
        
        //MARK: properties
        @Environment(EventListViewModel.self) var eventViewModel
        @Environment(AuthViewModel.self) var authViewModel
        
        //MARK: body
        var body: some View {
                NavigationStack {
                        VStack(spacing: 20) {
                                
                                // Avatar et Infos
                                VStack(spacing: 15) {
                                        
                                        Image("Avatar (4)")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 100, height: 100)
                                                .clipShape(Circle())
                                                .overlay(
                                                        Circle().stroke(Color.red, lineWidth: 3)
                                                )
                                                .shadow(radius: 10)
                                        
                                        // Infos Texte
                                        VStack(spacing: 5) {
                                                Text("Alejandro Sans")
                                                        .font(.title2)
                                                        .fontWeight(.bold)
                                                        .foregroundStyle(.white)
                                                
                                                Text(authViewModel.userSession?.email ?? "email@exemple.com")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.gray)
                                        }
                                }
                                .padding(.top, 30)
                                
                                Divider()
                                        .background(Color.gray.opacity(0.5))
                                        .padding(.vertical)
                                
                                // Menu / Options
                                List {
                                        Section {
                                                NavigationLink {
                                                        Text("Écran d'édition à venir")
                                                } label: {
                                                        Label("Modifier le profil", systemImage: "pencil")
                                                }
                                                
                                                NavigationLink(destination: MyEventsView()) {
                                                        HStack {
                                                                Image(systemName: "ticket.fill")
                                                                        .foregroundStyle(.white)
                                                                Text("Mes Evenements")
                                                                        .foregroundStyle(.white)
                                                                Spacer()
                                                                Image(systemName: "chevron.right")
                                                                        .foregroundStyle(.gray)
                                                        }
                                                        .padding()
                                                        .background(Color(white: 0.1))
                                                        .cornerRadius(10)
                                                }
                                                
                                                NavigationLink {
                                                        Text("Préférences")
                                                } label: {
                                                        Label("Paramètres", systemImage: "gear")
                                                }
                                        } header: {
                                                Text("Compte")
                                        }
                                        .listRowBackground(Color(white: 0.1))
                                        
                                        // Section Déconnexion
                                        Section {
                                                Button {
                                                        authViewModel.signOut()
                                                } label: {
                                                        Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                                                                .foregroundStyle(.red)
                                                }
                                        }
                                        .listRowBackground(Color(white: 0.1))
                                }
                                .scrollContentBackground(.hidden)
                        }
                        .background(Color.black.ignoresSafeArea())
                        .navigationTitle("User Profile")
                        .navigationBarTitleDisplayMode(.inline)
                }
        }
}

#Preview {
        
        let container = DIContainer()
        
        ProfileView()
                .environment(container.authViewModel)
                .environment(container.eventListViewModel)
}
