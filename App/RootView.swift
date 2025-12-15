//
//  ContentView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct RootView: View {
        // On instancie le ViewModel ici. C'est le "propriétaire" de l'état de connexion.
        @State private var authViewModel = AuthViewModel()
        
        var body: some View {
        
                if authViewModel.userSession != nil {
                        
                        EventListView(authViewModel: authViewModel)
                } else {
                        LoginView(viewModel: authViewModel)
                }
        }
}
