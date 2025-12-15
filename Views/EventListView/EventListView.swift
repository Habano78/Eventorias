//
//  EventListView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//


import SwiftUI

struct EventListView: View {
        //MARK: dependencies
        var authViewModel: AuthViewModel
        
        //MARK: properties
        @State private var viewModel = EventListViewModel()
        
        //MARK: body
        var body: some View {
                NavigationStack {
                        
                        List(viewModel.events) { event in
                                // Le NavigationLink rend la ligne cliquable et pousse la nouvelle vue
                                NavigationLink(destination: EventDetailView(event: event)) {
                                        HStack(spacing: 12) {
                                                Image(getImageName(for: event.category))
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 60, height: 60)
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                        Text(event.title)
                                                                .font(.headline)
                                                        
                                                        Text(event.location)
                                                                .font(.caption)
                                                                .foregroundStyle(.secondary)
                                                        
                                                        Text(event.date.formatted(date: .abbreviated, time: .shortened))
                                                                .font(.caption2)
                                                                .foregroundStyle(.gray)
                                                }
                                        }
                                        .padding(.vertical, 4)
                                }
                        }
                                .navigationTitle("Événements")
                                .toolbar {
                                        // Bouton de déconnexion
                                        ToolbarItem(placement: .topBarTrailing) {
                                                Button {
                                                        authViewModel.signOut()
                                                } label: {
                                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                                                .foregroundStyle(.red)
                                                }
                                        }
                                }
                        }
                }
                
                
                func getImageName(for category: EventCategory) -> String {
                        switch category {
                        case .music: return "Event MusicFestival"
                        case .art: return "Event ArtExhibition"
                        case .charity: return "Event CarityRun"
                        default: return "Event TechConf"
                        }
                }
        }
        
        #Preview {
                // Pour la preview, on passe un AuthViewModel vide
                EventListView(authViewModel: AuthViewModel())
        }
