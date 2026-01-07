//
//  DIContainer.swift
//  Eventorias
//
//  Created by Perez William on 16/12/2025.
//

import SwiftUI
import Observation
import FirebaseCore

@MainActor
@Observable
final class DIContainer {
        
        let service: EventServiceProtocol
        let authViewModel: AuthViewModel
        let eventListViewModel: EventListViewModel
        
        init(service: EventServiceProtocol) {
                self.service = service
                self.authViewModel = AuthViewModel(service: service)
                self.eventListViewModel = EventListViewModel(service: service)
        }
}
