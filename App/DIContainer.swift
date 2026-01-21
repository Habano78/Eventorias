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
        
        //MARK: Services
        let authService: any AuthServiceProtocol
        let userService: any UserServiceProtocol
        let eventService: any EventServiceProtocol
        private let imageService: any ImageStorageServiceProtocol
        
        
        //MARK: ViewModels
        let authViewModel: AuthViewModel
        let eventListViewModel: EventListViewModel
        
        
        //MARK: Init
        init() {
                self.authService = AuthService()
                self.imageService = ImageStorageService()
                self.userService = UserService(imageStorageService: imageService)
                self.eventService = EventService(imageStorageService: imageService)
                
                
                self.authViewModel = AuthViewModel(
                        authService: authService,
                        userService: userService
                )
                self.eventListViewModel = EventListViewModel(
                        eventService: eventService,
                        authService: authService
                )
        }
}
