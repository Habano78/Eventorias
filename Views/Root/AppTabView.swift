//
//  AppTabView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct AppTabView: View {
        
        var body: some View {
                
                TabView {
                        
                        // Liste
                        EventListView()
                                .tabItem {
                                        Image(systemName: "list.bullet")
                                        Text("Liste")
                                }
                                .accessibilityLabel("Onglet Liste des événements")
                        
                        // Map
                        EventMapView()
                                .tabItem {
                                        Image(systemName: "map")
                                        Text("Carte")
                                }
                                .accessibilityLabel("Onglet Carte")
                        
                        // Calendrier
                        CalendarView()
                                .tabItem {
                                        Image(systemName: "calendar")
                                        Text("Calendrier")
                                }
                                .accessibilityLabel("Onglet Calendrier")
                        
                        // Profil
                        ProfileView()
                                .tabItem {
                                        Image(systemName: "person")
                                        Text("Profil")
                                }
                                .accessibilityLabel("Onglet Profil utilisateur")
                }
                .tint(.blue)
        }
}
