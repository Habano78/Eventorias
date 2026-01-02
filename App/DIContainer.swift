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
        private let eventService: Service
        
        init() {
                self.eventService = Service.shared
                self.eventListViewModel = EventListViewModel()
                self.authViewModel = AuthViewModel()
        }
}
