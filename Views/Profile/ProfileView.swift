//
//  ProfileView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

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
        var currentUser: User? { authViewModel.currentUser }
        
        var myCreatedEvents: [Event] {
                guard let userID = currentUser?.id else { return [] }
                return eventListViewModel.events.filter { $0.userId == userID }
        }
        
        var myJoinedEvents: [Event] {
                guard let userID = currentUser?.id else { return [] }
                return eventListViewModel.events.filter { $0.attendees.contains(userID) }
        }
        
        // MARK: Body
        var body: some View {
                NavigationStack {
                        ZStack {
                                Color.black.ignoresSafeArea()
                                
                                if authViewModel.isLoading {
                                        ProgressView("Sauvegarde...")
                                                .tint(.white)
                                                .foregroundStyle(.white)
                                } else {
                                        Form {
                                                
                                                // SECTION 1 : AVATAR & INFO
                                                Section {
                                                        HStack {
                                                                Spacer()
                                                                VStack {
                                                                        
                                                                        if let selectedImage = selectedImage {
                                                                                Image(uiImage: selectedImage)
                                                                                        .resizable()
                                                                                        .scaledToFill()
                                                                                        .frame(width: 100, height: 100)
                                                                                        .clipShape(Circle())
                                                                        } else if let urlString = currentUser?.profileImageURL, let url = URL(string: urlString) {
                                                                                AsyncImage(url: url) { image in
                                                                                        image.resizable().scaledToFill()
                                                                                } placeholder: {
                                                                                        ProgressView()
                                                                                }
                                                                                .frame(width: 100, height: 100)
                                                                                .clipShape(Circle())
                                                                        } else {
                                                                                Image(systemName: "person.circle.fill")
                                                                                        .resizable()
                                                                                        .foregroundStyle(.gray)
                                                                                        .frame(width: 100, height: 100)
                                                                        }
                                                                        
                                                                        // Bouton modif photo
                                                                        PhotosPicker(selection: $selectedItem, matching: .images) {
                                                                                Text("Modifier la photo")
                                                                                        .font(.footnote)
                                                                                        .foregroundStyle(.blue)
                                                                        }
                                                                }
                                                                .padding(.vertical, 5)
                                                                Spacer()
                                                        }
                                                }
                                                .listRowBackground(Color.clear)
                                                
                                                // SECTION 2 : ÉDITION INFO
                                                Section("Informations Personnelles") {
                                                        TextField("Nom complet", text: $name)
                                                        
                                                        HStack {
                                                                Text("Email")
                                                                Spacer()
                                                                Text(currentUser?.email ?? "")
                                                                        .foregroundStyle(.gray)
                                                        }
                                                }
                                                
                                                // STATISTIQUES
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
                                                
                                                // MES ÉVÉNEMENTS
                                                if !myCreatedEvents.isEmpty {
                                                        Section("Mes Événements Créés") {
                                                                ForEach(myCreatedEvents) { event in
                                                                        NavigationLink(destination: EventDetailView(event: event)) {
                                                                                Text(event.title)
                                                                        }
                                                                }
                                                                // Suppression par swipe
                                                                .onDelete { indexSet in
                                                                        deleteEvents(at: indexSet)
                                                                }
                                                        }
                                                }
                                                
                                                // RÉGLAGES & ACTIONS
                                                Section("Préférences & Actions") {
                                                        Toggle("Notifications", isOn: $isNotificationsEnabled)
                                                                .tint(.green)
                                                        
                                                        Button {
                                                                saveProfileChanges()
                                                        } label: {
                                                                Text("Enregistrer les modifications")
                                                                        .foregroundStyle(.blue)
                                                        }
                                                        
                                                        Button(role: .destructive) {
                                                                authViewModel.signOut()
                                                        } label: {
                                                                Text("Se déconnecter")
                                                        }
                                                }
                                        }
                                        .scrollContentBackground(.hidden)
                                }
                        }
                        .navigationTitle("Mon Profil")
                        .onAppear {
                                if let user = currentUser {
                                        self.name = user.name ?? ""
                                        self.isNotificationsEnabled = user.isNotificationsEnabled
                                }
                        }
                        // Gestion photo
                        .onChange(of: selectedItem) { _, newItem in
                                Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                                self.selectedImage = uiImage
                                        }
                                }
                        }
                }
                .preferredColorScheme(.dark)
        }
        
        // MARK: Helper Functions
        
        private func saveProfileChanges() {
                authViewModel.updateProfile(
                        name: name,
                        isNotifEnabled: isNotificationsEnabled,
                        image: selectedImage
                )
        }
        
        private func deleteEvents(at indexSet: IndexSet) {
                
                let eventsToDelete = indexSet.map { myCreatedEvents[$0] }
                
                for event in eventsToDelete {
                        withAnimation {
                                eventListViewModel.deleteEvent(event)
                        }
                }
        }
}
