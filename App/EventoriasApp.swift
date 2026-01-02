//
//  EventoriasApp.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication,
                         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
                return true
        }
}

@main
struct EventoriasApp: App {
        
        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        @State private var container: DIContainer
        
        
        //MARK: Init
        init() {
                // Conf
                if FirebaseApp.app() == nil {
                        FirebaseApp.configure()
                }
                
                // Init
                _container = State(initialValue: DIContainer())
                
                requestNotificationPermission()
        }
        
        func requestNotificationPermission() {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if granted {
                        print("✅ Permission Notifications accordée !")
                    } else if let error = error {
                        print("❌ Erreur Permission : \(error.localizedDescription)")
                    } else {
                        print("⚠️ Permission Notifications refusée.")
                    }
                }
            }
        
        //MARK: Body
        var body: some Scene {
                WindowGroup {
                        RootView()
                                .environment(container.authViewModel)
                                .environment(container.eventListViewModel)
                                .preferredColorScheme(.dark)
                }
        }
}
