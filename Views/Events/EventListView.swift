//
//  EventListView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//


import SwiftUI

struct EventListView: View {
        
        var authViewModel: AuthViewModel
        
        @State private var viewModel = EventListViewModel()
        @State private var searchText = ""
        @State private var showCreateSheet = false
        
        //MARK: body
        var body: some View {
                NavigationStack {
                        
                        ZStack(alignment: .bottomTrailing) {
                                
                                //  FOND NOIR
                                Color.black.ignoresSafeArea()
                                
                                VStack(spacing: 16) {
                                        
                                        HStack {
                                                HStack {
                                                        Image(systemName: "magnifyingglass")
                                                                .foregroundStyle(.gray)
                                                        TextField("Search", text: $searchText)
                                                }
                                                .padding(10)
                                                .background(Color(white: 0.2))
                                                .cornerRadius(20)
                                                
                                                // Bouton Sort
                                                Button {} label: {
                                                        HStack {
                                                                Image(systemName: "arrow.up.arrow.down")
                                                                Text("Sorting")
                                                        }
                                                        .font(.caption)
                                                        .padding(10)
                                                        .background(Color(white: 0.2))
                                                        .cornerRadius(20)
                                                        .foregroundStyle(.white)
                                                }
                                        }
                                        .padding(.horizontal)
                                        
                                        // 2. La Liste
                                        ScrollView {
                                                LazyVStack(spacing: 12) {
                                                        ForEach(viewModel.events) { event in
                                                                NavigationLink(destination: EventDetailView(event: event)) {
                                                                        EventRowView(event: event)
                                                                }
                                                        }
                                                }
                                                .padding()
                                        }
                                }
                                
                                // Le Bouton Flottant (+)
                                Button {
                                        showCreateSheet = true
                                } label: {
                                        Image("Button - Add new event")
                                }
                                .padding()
                                .offset(y: -10)
                        }
                        .sheet(isPresented: $showCreateSheet) {
                            AddEventView(viewModel: viewModel)
                        }
                        .navigationTitle("")
                }
                .preferredColorScheme(.dark)
        }
}

//MARK: preview
#Preview {
        EventListView(authViewModel: AuthViewModel())
}
