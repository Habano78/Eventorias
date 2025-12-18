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
        
        @Environment(AuthViewModel.self) var authViewModel
        
        // États locaux pour l'édition
        @State private var name: String = ""
        @State private var isNotificationsEnabled: Bool = false
        @State private var selectedItem: PhotosPickerItem? = nil
        @State private var selectedImage: UIImage? = nil
        
        
        //MARK: body
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
                                                // SECTION 1: AVATAR
                                                Section {
                                                        HStack {
                                                                Spacer()
                                                                VStack {
                                                                        // Affichage de l'image (Locale ou Distante ou Placeholder)
                                                                        if let selectedImage = selectedImage {
                                                                                Image(uiImage: selectedImage)
                                                                                        .resizable()
                                                                                        .scaledToFill()
                                                                                        .frame(width: 100, height: 100)
                                                                                        .clipShape(Circle())
                                                                        } else if let urlString = authViewModel.currentUser?.profileImageURL, let url = URL(string: urlString) {
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
                                                                        
                                                                        // Bouton Changement Photo
                                                                        PhotosPicker(selection: $selectedItem, matching: .images) {
                                                                                Text("Modifier la photo")
                                                                                        .font(.footnote)
                                                                                        .foregroundStyle(.blue)
                                                                        }
                                                                }
                                                                Spacer()
                                                        }
                                                }
                                                .listRowBackground(Color.clear)
                                                
                                                // SECTION INFOS
                                                Section("Informations Personnelles") {
                                                        TextField("Nom complet", text: $name)
                                                        
                                                        HStack {
                                                                Text("Email")
                                                                Spacer()
                                                                Text(authViewModel.userSession?.email ?? "")
                                                                        .foregroundStyle(.gray)
                                                        }
                                                }
                                                
                                                // Switch notifications
                                                Section("Préférences") {
                                                        Toggle("Notifications", isOn: $isNotificationsEnabled)
                                                                .tint(.green) // Couleur active
                                                }
                                                
                                                // ACTIONS
                                                Section {
                                                        Button {
                                                                authViewModel.updateProfile(
                                                                        name: name,
                                                                        isNotifEnabled: isNotificationsEnabled,
                                                                        image: selectedImage
                                                                )
                                                        } label: {
                                                                Text("Enregistrer les modifications")
                                                                        .frame(maxWidth: .infinity)
                                                                        .foregroundStyle(.white)
                                                        }
                                                        .listRowBackground(Color.blue)
                                                        
                                                        Button(role: .destructive) {
                                                                authViewModel.signOut()
                                                        } label: {
                                                                Text("Se déconnecter")
                                                                        .frame(maxWidth: .infinity)
                                                        }
                                                }
                                        }
                                        .scrollContentBackground(.hidden)
                                }
                        }
                        .navigationTitle("Mon Profil")
                        .onAppear {
                                /// Charger les données existantes dans les champs
                                if let user = authViewModel.currentUser {
                                        self.name = user.name ?? ""
                                        self.isNotificationsEnabled = user.isNotificationsEnabled
                                }
                        }
                        /// Gestion de la sélection photo
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
}

#Preview {
        ProfileView()
                .environment(AuthViewModel())
}
