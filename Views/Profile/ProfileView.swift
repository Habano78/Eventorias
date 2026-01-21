//
//  ProfileView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
        
        // MARK: Dependencies
        @Environment(AuthViewModel.self) var authViewModel
        @Environment(EventListViewModel.self) var eventListViewModel
        
        // MARK: Local States
        @State private var name: String = ""
        @State private var isNotificationsEnabled: Bool = false
        @State private var selectedItem: PhotosPickerItem? = nil
        @State private var selectedImage: UIImage? = nil
        
        // MARK: Computed Properties
        ///
        var currentUser: User? { authViewModel.currentUser }
        ///
        var myCreatedEvents: [Event] {
                guard let userID = authViewModel.activeSessionId else { return [] }
                return eventListViewModel.events.filter { $0.userId == userID }
        }
        
        ///
        var myJoinedEvents: [Event] {
                guard let userID = authViewModel.activeSessionId else { return [] }
                return eventListViewModel.events.filter { $0.attendees.contains(userID) }
        }
        
        // MARK: - BODY PRINCIPAL
        var body: some View {
                NavigationStack {
                        ZStack {
                                Color.black.ignoresSafeArea()
                                
                                if authViewModel.isLoading {
                                        ProgressView("Sauvegarde...")
                                                .tint(.white)
                                                .foregroundStyle(.white)
                                } else {
                                        mainForm
                                }
                        }
                        .navigationTitle("Mon Profil")
                        
                        // CHARGEMENT INITIAL
                        .onAppear {
                                loadUserData()
                                
                                if authViewModel.currentUser == nil, let userID = authViewModel.activeSessionId {
                                        Task { await authViewModel.fetchUser(fireBaseUserId: userID) }
                                }
                        }
                        .onChange(of: authViewModel.currentUser) { _, _ in
                                loadUserData()
                        }
                }
                .preferredColorScheme(.dark)
        }
}

// MARK: - SOUS-VUES
extension ProfileView {
        
        // Formulaire principal
        var mainForm: some View {
                Form {
                        avatarSection
                        infoSection
                        statsSection
                        eventsSection
                        actionSection
                }
                .scrollContentBackground(.hidden)
        }
        
        // Section Avatar
        var avatarSection: some View {
                Section {
                        HStack {
                                Spacer()
                                VStack {
                                        if let selectedImage = selectedImage {
                                                Image(uiImage: selectedImage)
                                                        .resizable().scaledToFill()
                                                        .frame(width: 100, height: 100).clipShape(Circle())
                                        } else if let urlString = currentUser?.profileImageURL, let url = URL(string: urlString) {
                                                AsyncImage(url: url) { image in
                                                        image.resizable().scaledToFill()
                                                } placeholder: {
                                                        ProgressView()
                                                }
                                                .frame(width: 100, height: 100).clipShape(Circle())
                                        } else {
                                                Image(systemName: "person.circle.fill")
                                                        .resizable().foregroundStyle(.gray)
                                                        .frame(width: 100, height: 100)
                                        }
                                        
                                        PhotosPicker(selection: $selectedItem, matching: .images) {
                                                Text("Modifier la photo").font(.footnote).foregroundStyle(.blue)
                                        }
                                        .padding(.vertical, 5)
                                }
                                Spacer()
                        }
                }
                .listRowBackground(Color.clear)
        }
        
        // Section Infos
        var infoSection: some View {
                Section("Informations Personnelles") {
                        TextField("Nom complet", text: $name)
                        HStack {
                                Text("Email")
                                Spacer()
                                Text(currentUser?.email ?? "").foregroundStyle(.gray)
                        }
                }
        }
        
        // Section Statistique
        var statsSection: some View {
                Section {
                        HStack {
                                VStack {
                                        Text("\(myCreatedEvents.count)")
                                                .font(.title2).fontWeight(.bold).foregroundStyle(.blue)
                                        Text("Créés").font(.caption).foregroundStyle(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                
                                Divider()
                                
                                VStack {
                                        Text("\(myJoinedEvents.count)")
                                                .font(.title2).fontWeight(.bold).foregroundStyle(.green)
                                        Text("Rejoints").font(.caption).foregroundStyle(.gray)
                                }
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 5)
                }
        }
        
        // Section Événements
        @ViewBuilder
        var eventsSection: some View {
                if !myCreatedEvents.isEmpty {
                        Section("Mes Événements Créés") {
                                ForEach(myCreatedEvents) { event in
                                        NavigationLink(destination: EventDetailView(event: event)) {
                                                Text(event.title)
                                        }
                                }
                                .onDelete { indexSet in
                                        deleteEvents(at: indexSet)
                                }
                        }
                }
        }
        
        // Section Sauvegarde & Déconnexion propre
        var actionSection: some View {
                Section("Préférences & Actions") {
                        Toggle("Notifications", isOn: $isNotificationsEnabled)
                                .tint(.green)
                        
                        Button {
                                Task { await saveProfileChanges() }
                        } label: {
                                Text("Enregistrer les modifications").foregroundStyle(.blue)
                        }
                        .disabled(authViewModel.isLoading)
                        
                        // DÉCONNEXION SÉCURISÉE
                        Button(role: .destructive) {
                                eventListViewModel.clearData() /// Vide la mémoire locale
                                authViewModel.signOut()        /// Coupe la connexion Firebase
                        } label: {
                                Text("Se déconnecter")
                        }
                        .disabled(authViewModel.isLoading)
                }
        }
        
        // MARK: - Fonctions Helper
        
        func loadUserData() {
                if let user = currentUser {
                        self.name = user.name ?? ""
                        self.isNotificationsEnabled = user.isNotificationsEnabled
                }
        }
        
        func saveProfileChanges() async {
                await authViewModel.updateProfile(
                        name: name,
                        isNotifEnabled: isNotificationsEnabled,
                        image: selectedImage
                )
        }
        
        func deleteEvents(at indexSet: IndexSet) {
                let eventsToDelete = indexSet.map { myCreatedEvents[$0] }
                Task {
                        for event in eventsToDelete {
                                await eventListViewModel.deleteEvent(event)
                        }
                }
        }
}
