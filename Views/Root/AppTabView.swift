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
                        
                        EventListView()
                                .tabItem {
                                        Image ("Button - Event")
                                }
                        
                        ProfileView()
                                .tabItem {
                                        Image ("Button - Profile")
                                }
                }
        }
}

#Preview {
        let container = DIContainer()
        
        AppTabView()
                .environment(container.authViewModel)
                .environment(container.eventListViewModel)
}
