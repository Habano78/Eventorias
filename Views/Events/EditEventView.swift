//
//  EditEventView.swift
//  Eventorias
//
//  Created by Perez William on 28/12/2025.
//

import SwiftUI
import PhotosUI

struct EditEventView: View {
        
        let event: Event
        @Environment(EventListViewModel.self) var eventListViewModel
        @Environment(\.dismiss) var dismiss
        
        // États locaux
        @State private var title = ""
        @State private var description = ""
        @State private var location = ""
        @State private var date = Date()
        @State private var selectedCategory: EventCategory = .music
        
        // Gestion Image
        @State private var selectedItem: PhotosPickerItem? = nil
        @State private var selectedImage: UIImage? = nil
        
        //MARK: Body
        var body: some View {
                NavigationStack {
                        Form {
                                Section("Infos") {
                                        TextField("Titre", text: $title)
                                        Picker("Catégorie", selection: $selectedCategory) {
                                                ForEach(EventCategory.allCases) { cat in
                                                        Text(cat.rawValue).tag(cat)
                                                }
                                        }
                                }
                                
                                Section("Détails") {
                                        DatePicker("Date", selection: $date)
                                        TextField("Lieu", text: $location)
                                        TextEditor(text: $description).frame(height: 100)
                                }
                                
                                Section("Photo") {
                                        if let newImage = selectedImage {
                                                Image(uiImage: newImage)
                                                        .resizable().scaledToFill()
                                                        .frame(height: 200).clipped().cornerRadius(10)
                                        } else if let urlString = event.imageURL, let url = URL(string: urlString) {
                                                AsyncImage(url: url) { img in
                                                        img.resizable().scaledToFill()
                                                } placeholder: {
                                                        ProgressView()
                                                }
                                                .frame(height: 200).clipped().cornerRadius(10)
                                        }
                                        
                                        PhotosPicker(selection: $selectedItem, matching: .images) {
                                                Label("Changer la photo", systemImage: "photo")
                                        }
                                }
                        }
                        .navigationTitle("Modifier")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                        Button("Annuler") { dismiss() }
                                }
                                ToolbarItem(placement: .confirmationAction) {
                                        Button("Enregistrer") {
                                                saveChanges()
                                        }
                                        .disabled(title.isEmpty)
                                }
                        }
                        .onAppear {
                                self.title = event.title
                                self.description = event.description
                                self.location = event.location
                                self.date = event.date
                                self.selectedCategory = event.category
                        }
                        .onChange(of: selectedItem) { _, newItem in
                                Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                                           let uiImage = UIImage(data: data) {
                                                self.selectedImage = uiImage
                                        }
                                }
                        }
                }
        }
        
        private func saveChanges() {
                let newImageData = selectedImage?.jpegData(compressionQuality: 0.5)
                
                eventListViewModel.editEvent(
                        event: event,
                        title: title,
                        description: description,
                        date: date,
                        location: location,
                        category: selectedCategory,
                        newImageData: newImageData
                )
                dismiss()
        }
}
