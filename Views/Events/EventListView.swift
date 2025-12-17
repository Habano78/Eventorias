//
//  EventListView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//


import SwiftUI

struct EventListView: View {
        
        @Environment(EventListViewModel.self) var viewModel
        
        @State private var searchText = ""
        @State private var showAddEventSheet = false
        
        ///Logique de filtrage
        var filteredEvents: [Event] {
                if searchText.isEmpty {
                        return viewModel.events
                } else {
                        return viewModel.events.filter { event in
                                event.title.localizedCaseInsensitiveContains(searchText)
                        }
                }
        }
        
        var body: some View {
                NavigationStack {
                        Group {
                                if filteredEvents.isEmpty {
                                        VStack(spacing: 20) {
                                                Image(systemName: searchText.isEmpty ? "calendar.badge.plus" : "magnifyingglass")
                                                        .font(.system(size: 50))
                                                        .foregroundStyle(.gray)
                                               
                                                Text(searchText.isEmpty ? "Aucun événement" : "Aucun résultat")
                                                        .font(.headline)
                                                        .foregroundStyle(.gray)
                                                
                                                if searchText.isEmpty {
                                                        Text("Cliquez sur + pour créer le premier !")
                                                                .font(.caption)
                                                                .foregroundStyle(.secondary)
                                                }
                                        }
                                } else {
                                        // La Liste
                                        List {
                                                ForEach(filteredEvents) { event in
                                                        
                                                        ZStack {
                                                                NavigationLink(destination: EventDetailView(event: event)) {
                                                                        EmptyView()
                                                                }
                                                                .opacity(0)
                                                                
                                                                EventRowView(event: event)
                                                        }
                                                        .listRowSeparator(.hidden)
                                                        .listRowInsets(EdgeInsets(top: 8, leading: 1, bottom: 1, trailing: 1))
                                                }
                                                .onDelete(perform: viewModel.deleteEvent)
                                        }
                                        .listStyle(.plain)
                                }
                        }
                        .navigationTitle("")
                        // Barre de recherche
                        .searchable(text: $searchText, prompt: "Rechercher un événement...")
                        .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                        Button {
                                                showAddEventSheet.toggle()
                                        } label: {
                                                Image(systemName: "plus.circle.fill")
                                                        .font(.title2)
                                                        .foregroundStyle(Color.red)
                                        }
                                }
                        }
                        .sheet(isPresented: $showAddEventSheet) {
                                AddEventView(viewModel: viewModel)
                        }
                }
                .preferredColorScheme(.dark)
        }
}

#Preview {
        EventListView()
                .environment(EventListViewModel())
}
