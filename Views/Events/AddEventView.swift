//
//  AddEventView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct AddEventView: View {
        
        var viewModel: EventListViewModel
        
        @Environment(\.dismiss) var dismiss
        
        
        // Les champs du formulaire
        @State private var title = ""
        @State private var description = ""
        @State private var location = ""
        @State private var date = Date()
        @State private var selectedCategory: EventCategory = .music
        
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
                                        // TextEditor permet d'écrire plusieurs lignes
                                        TextEditor(text: $description)
                                                .frame(height: 100)
                                }
                        }
                        .navigationTitle("Nouvel Événement")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                                // Bouton Annuler
                                ToolbarItem(placement: .cancellationAction) {
                                        Button("Annuler") {
                                                dismiss()
                                        }
                                }
                                
                                // Bouton Créer
                                ToolbarItem(placement: .confirmationAction) {
                                        
                                        Button("Créer") {
                                                viewModel.addEvent(
                                                        title: title,
                                                        description: description,
                                                        date: date,
                                                        location: location,
                                                        category: selectedCategory
                                                )
                                                dismiss()
                                        }
                                        .disabled(title.isEmpty)
                                }
                        }
                }
                .preferredColorScheme(.dark)
        }
}

#Preview {
        AddEventView(viewModel: EventListViewModel())
}
