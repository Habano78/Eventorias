//
//  AppTabView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct AppTabView: View {
        
        //MARK: dependencies
        var authViewModel: AuthViewModel
        
        //MARK: body
        var body: some View {
                TabView {
                        
                        EventListView(authViewModel: authViewModel)
                                .tabItem {
                                        Label("Explorer", systemImage: "calendar")
                                }
                        
                        Text("Écran de création à venir")
                                .tabItem {
                                        Label("Créer", systemImage: "plus.circle.fill")
                                }
                        
                        Text("Écran de profil à venir")
                                .tabItem {
                                        Label("Profil", systemImage: "person.crop.circle")
                                }
                }
                .tint(.blue)
        }
}

#Preview {
        AppTabView(authViewModel: AuthViewModel())
}
