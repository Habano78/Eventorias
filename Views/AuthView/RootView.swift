//
//  ContentView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct RootView: View {
        
        //MARK: instantiation
        @State private var authViewModel = AuthViewModel()
        
        
        var body: some View {
                
                if authViewModel.userSession != nil {
                        
                        AppTabView(authViewModel: authViewModel)
                        
                } else {
                        AuthentificationView(viewModel: authViewModel)
                }
        }
}
