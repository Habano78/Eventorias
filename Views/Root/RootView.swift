//
//  RootView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct RootView: View {
        
        @Environment(AuthViewModel.self) var authViewModel
        
        var body: some View {
                Group {
                        if authViewModel.isUserSignedIn {
                                AppTabView()
                        }
                        else {
                                LoginView()
                        }
                }
                .overlay {
                        if authViewModel.isLoading {
                                ZStack {
                                        Color.black.ignoresSafeArea()
                                        ProgressView()
                                                .tint(.white)
                                                .controlSize(.large)
                                }
                        }
                }
        }
}
