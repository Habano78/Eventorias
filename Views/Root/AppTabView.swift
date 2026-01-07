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
                    
                    // Map
                    EventMapView()
                        .tabItem {
                            Image(systemName: "map")
                            Text("Carte")
                        }

                    // Calendrier
                    CalendarView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Calendrier")
                        }
                    
                    // Profil
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person")
                            Text("Profil")
                        }
                }
                .tint(.blue)
        }
}

#Preview {
        let container = DIContainer(service: Service.shared)
        
        AppTabView()
                .environment(container.authViewModel)
                .environment(container.eventListViewModel)
                .preferredColorScheme(.dark)
}
