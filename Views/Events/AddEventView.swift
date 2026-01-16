//
//  AddEventView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI
import FirebaseAuth
import PhotosUI

struct AddEventView: View {
        
        // MARK: properties
        @Environment(EventListViewModel.self) var eventListViewModel
        @Environment(\.dismiss) var dismiss
        
        /// Champs du formulaire
        @State private var title = ""
        @State private var description = ""
        @State private var location = ""
        @State private var date = Date()
        @State private var selectedCategory: EventCategory = .music
        
        /// Gestion Image
        @State private var selectedItem: PhotosPickerItem? = nil
        @State private var selectedImageData: Data? = nil
        @State private var selectedImage: UIImage? = nil
        
        @State private var isSaving = false
        
        // MARK: body
        var body: some View {
                NavigationStack {
                        Form {
                                /// Infos
                                Section(header: Text("Détails de l'événement")) {
                                        TextField("Titre de l'événement", text: $title)
                                                .accessibilityLabel("Titre de l'événement")
                                                .accessibilityHint("Obligatoire")
                                        
                                        Picker("Catégorie", selection: $selectedCategory) {
                                                ForEach(EventCategory.allCases) { category in
                                                        Text(category.rawValue).tag(category)
                                                }
                                        }
                                        .accessibilityLabel("Catégorie")
                                        .accessibilityHint("Sélectionnez le type d'événement")
                                }
                                
                                /// Date et Lieu
                                Section(header: Text("Quand et Où ?")) {
                                        DatePicker("Date", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                                .accessibilityLabel("Date et heure de début")
                                        
                                        TextField("Lieu (Ville, Adresse)", text: $location)
                                                .accessibilityLabel("Lieu de l'événement")
                                                .accessibilityHint("Ville ou adresse précise")
                                }
                                
                                /// Description
                                Section(header: Text("Description")) {
                                        TextEditor(text: $description)
                                                .frame(height: 100)
                                                .accessibilityLabel("Description détaillée")
                                                .accessibilityHint("Décrivez le programme de l'événement")
                                }
                                
                                /// Photo
                                Section(header: Text("Photo de l'événement")) {
                                        HStack {
                                                if let image = selectedImage {
                                                        Image(uiImage: image)
                                                                .resizable()
                                                                .scaledToFill()
                                                                .frame(width: 80, height: 80)
                                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                                .accessibilityLabel("Aperçu de la photo sélectionnée")
                                                } else {
                                                        /// Placeholder
                                                        RoundedRectangle(cornerRadius: 10)
                                                                .fill(Color.gray.opacity(0.2))
                                                                .frame(width: 80, height: 80)
                                                                .overlay {
                                                                        Image(systemName: "photo")
                                                                                .foregroundStyle(.gray)
                                                                }
                                                                .accessibilityHidden(true)
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
                                                .accessibilityLabel("Choisir une photo dans la bibliothèque")
                                                .accessibilityHint("Ouvre la galerie photos")
                                        }
                                        .padding(.vertical, 5)
                                }
                        }
                        .navigationTitle("Nouvel Événement")
                        .navigationBarTitleDisplayMode(.inline)
                        
                        /// Gestion de la sélection d'image
                        .onChange(of: selectedItem) { oldValue, newItem in
                                
                                guard let item = newItem else { return }
                                
                                Task {
                                        
                                        do {
                                                if let data = try await item.loadTransferable(type: Data.self),
                                                   let uiImage = UIImage(data: data) {
                                                        
                                                        selectedImage = uiImage
                                                        
                                                } else {
                                                        print("Aucune donnée trouvée dans l'image sélectionnée.")
                                                }
                                        } catch {
                                                print("Erreur chargement image : \(error.localizedDescription)")
                                        }
                                }
                        }
                        
                        .toolbar {
                                /// Bouton Annuler
                                ToolbarItem(placement: .cancellationAction) {
                                        Button("Annuler") {
                                                dismiss()
                                        }
                                        .accessibilityHint("Ferme la fenêtre sans enregistrer")
                                }
                                
                                /// Bouton Créer
                                ToolbarItem(placement: .confirmationAction) {
                                        Button {
                                                saveEvent()
                                        } label: {
                                                if isSaving {
                                                        ProgressView()
                                                } else {
                                                        Text("Ajouter")
                                                }
                                        }
                                        .disabled(title.isEmpty || location.isEmpty || isSaving)
                                        .accessibilityLabel("Enregistrer l'événement")
                                        .accessibilityHint(title.isEmpty || location.isEmpty ? "Remplissez le titre et le lieu pour activer ce bouton" : "Crée l'événement et ferme la fenêtre")
                                }
                        }
                }
                .preferredColorScheme(.dark)
                .interactiveDismissDisabled(isSaving)
        }
        
        // MARK: MiseAJour
        
        private func saveEvent() {
                isSaving = true
                
                Task {
                        
                        var latitude = 0.0
                        var longitude = 0.0
                        
                        do {
                                let coordinates = try await LocationHelper.getCoordinates(from: location)
                                latitude = coordinates.latitude
                                longitude = coordinates.longitude
                        } catch {
                                print("Erreur GPS : \(error.localizedDescription). Utilisation par défaut (0,0).")
                        }
                        
                        let imageData = selectedImage?.jpegData(compressionQuality: 0.5)
                        
                        await eventListViewModel.addEvent(
                                title: title,
                                description: description,
                                date: date,
                                location: location,
                                category: selectedCategory,
                                latitude: latitude,
                                longitude: longitude,
                                newImageData: imageData
                        )
                        
                        isSaving = false
                        dismiss()
                }
        }
}
