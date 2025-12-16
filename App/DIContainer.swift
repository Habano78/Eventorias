//
//  DIContainer.swift
//  Eventorias
//
//  Created by Perez William on 16/12/2025.
//

import SwiftUI
import Observation
import FirebaseCore

@Observable
class DIContainer {
        
        var authViewModel: AuthViewModel
        var eventListViewModel: EventListViewModel
        
        init() {
                
                if FirebaseApp.app() == nil {
                        FirebaseApp.configure()
                }
                self.authViewModel = AuthViewModel()
                self.eventListViewModel = EventListViewModel()
        }
}
