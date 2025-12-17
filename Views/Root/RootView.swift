//
//  ContentView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct RootView: View {
        
        //MARK: dependence
        @Environment(AuthViewModel.self) var authViewModel
        
        //MARK: body
        var body: some View {
        
                if authViewModel.userSession != nil {
                        AppTabView()
                } else {
                        WelcomeView()
                }
        }
}
