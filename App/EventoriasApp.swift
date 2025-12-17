//
//  EventoriasApp.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI
import FirebaseCore


@main
struct EventoriasApp: App {
        
        @State private var container = DIContainer()
        
        var body: some Scene {
                WindowGroup {
                        
                        RootView(authViewModel: container.authViewModel)
                                .environment(container)
                                .environment(container.eventListViewModel)
                                .preferredColorScheme(.dark)
                }
        }
}
