//
//  AddEventView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//
//

import SwiftUI
import FirebaseAuth
import PhotosUI

struct AddEventView: View {
        
        //MARK: properties
        @Environment(EventListViewModel.self) var eventListViewModel
        @Environment(\.dismiss) var dismiss
        
        // Champs du formulaire
        @State private var title = ""
        @State private var description = ""
        @State private var location = ""
        @State private var date = Date()
        @State private var selectedCategory: EventCategory = .music
        
        // Gestion Image
        @State private var selectedItem: PhotosPickerItem? = nil
        @State private var selectedImageData: Data? = nil
        @State private var selectedImage: UIImage? = nil
        
        
        //MARK: body
        var body: some View {
                NavigationStack {
                        Form {
                                /// Section 1 : Infos
                                Section(header: Text("Détails de l'événement")) {
                                        TextField("Titre de l'événement", text: $title)
                                        
                                        Picker("Catégorie", selection: $selectedCategory) {
                                                ForEach(EventCategory.allCases) { category in
                                                        Text(category.rawValue).tag(category)
                                                }
                                        }
                                }
                                
                                /// Section 2 : Date et Lieu
                                Section(header: Text("Quand et Où ?")) {
                                        DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                                        TextField("Lieu (Ville, Adresse)", text: $location)
                                }
                                
                                /// Section 3 : Description
                                Section(header: Text("Description")) {
                                        TextEditor(text: $description)
                                                .frame(height: 100)
                                }
                                
                                /// Section 4 : Photo
                                Section(header: Text("Photo de l'événement")) {
                                        HStack {
                                                /// Aperçu de l'image sélectionnée
                                                if let image = selectedImage {
                                                        Image(uiImage: image)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 80, height: 80)
                                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                } else {
                                                        /// Placeholder
                                                        RoundedRectangle(cornerRadius: 10)
                                                                .fill(Color.gray.opacity(0.2))
                                                                .frame(width: 80, height: 80)
                                                                .overlay {
                                                                        Image(systemName: "photo")
                                                                                .foregroundStyle(.gray)
                                                                }
                                                }
                                                
                                                Spacer()
                                                
                                                // PhotosPicker
                                                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                                        HStack {
                                                                Image(systemName: "photo.badge.plus")
                                                                Text("Choisir une photo")
                                                        }
                                                        .foregroundStyle(.blue)
                                                }
                                        }
                                        .padding(.vertical, 5)
                                }
                        }
                        .navigationTitle("Nouvel Événement")
                        .navigationBarTitleDisplayMode(.inline)
                        
                        .onChange(of: selectedItem) { oldValue, newItem in
                                Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                                
                                                self.selectedImage = uiImage
                                                self.selectedImageData = uiImage.jpegData(compressionQuality: 0.5)
                                        }
                                }
                        }
                        
                        .toolbar {
                                // Bouton Annuler
                                ToolbarItem(placement: .cancellationAction) {
                                        Button("Annuler") {
                                                dismiss()
                                        }
                                }
                                
                                // Bouton Créer
                                ToolbarItem(placement: .confirmationAction) {
                                        
                                        // Dans le body de ta Vue
                                        Button("Ajouter l'événement") {
                                                saveEvent() // ✅ Appel propre et court
                                        }
                                        // .disabled(...) // Tes modifiers éventuels
                                        .disabled(title.isEmpty)
                                }
                        }
                }
                .preferredColorScheme(.dark)
        }
        
        private func saveEvent() {
                // 1. On prépare l'image (conversion en Data) en dehors du Button
                // Cela soulage énormément le compilateur
                let imageData = selectedImage?.jpegData(compressionQuality: 0.5)
                
                // 2. On appelle la méthode du ViewModel
                eventListViewModel.addEvent(
                        title: title, // Tes variables @State
                        description: description,
                        date: date,
                        locationName: location,
                        category: selectedCategory,
                        imageData: imageData
                )
                
                // 3. On ferme la vue
                dismiss()
        }
}

#Preview {
        AddEventView()
}
