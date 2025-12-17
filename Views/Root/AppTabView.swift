//
//  AppTabView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct AppTabView: View {
        
        //MARK: dependencies
        @Environment(AuthViewModel.self) var authViewModel
        
        //MARK: body
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
        AppTabView()
                .environment(AuthViewModel())
}
