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
                        
                        EventListView()
                                .tabItem {
                                        Image ("Button - Event")
                                }
                        
                        ProfileView(authViewModel: authViewModel)
                                .tabItem {
                                        Image ("Button - Profile")
                                }
                }
        }
}

#Preview {
        AppTabView(authViewModel: AuthViewModel())
}
