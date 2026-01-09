//
//  EventListView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct EventListView: View {
        
        // MARK: Properties
        @Environment(EventListViewModel.self) var viewModel
        @Environment(\.horizontalSizeClass) var sizeClass
        
        @State private var showAddSheet = false
        
        let columns = [
                GridItem(.adaptive(minimum: 320), spacing: 20)
        ]
        
        // MARK: Body
        var body: some View {
                NavigationStack {
                        ZStack {
                                // Fond
                                Color.black.ignoresSafeArea()
                                
                                if viewModel.isLoading && viewModel.events.isEmpty {
                                        ProgressView()
                                                .tint(.white)
                                } else if viewModel.events.isEmpty {
                                        ContentUnavailableView("Aucun événement", systemImage: "calendar.badge.exclamationmark", description: Text("Soyez le premier à créer un événement !"))
                                                .foregroundStyle(.white)
                                } else {
                                        
                                        /// Adaptation IPAD/Iphone
                                        if sizeClass == .regular {
                                                /// IPAD
                                                ScrollView {
                                                        LazyVGrid(columns: columns, spacing: 20) {
                                                                ForEach(viewModel.events) { event in
                                                                        NavigationLink(destination: EventDetailView(event: event)) {
                                                                                EventRowView(event: event)
                                                                                        .frame(height: 120)
                                                                        }
                                                                        .buttonStyle(PlainButtonStyle())
                                                                }
                                                        }
                                                        .padding()
                                                }
                                                .background(Color.black)
                                        } else {
                                                // IPHONE
                                                List {
                                                        ForEach(viewModel.events) { event in
                                                                NavigationLink(destination: EventDetailView(event: event)) {
                                                                        EventRowView(event: event)
                                                                }
                                                                .listRowBackground(Color.clear)
                                                                .listRowSeparator(.hidden)
                                                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                                        }
                                                }
                                                .listStyle(.plain)
                                                .refreshable {
                                                        await viewModel.fetchEvents()
                                                }
                                        }
                                }
                        }
                        .navigationTitle("Événements")
                        .toolbar {
                                ToolbarItem(placement: .primaryAction) {
                                        Button {
                                                showAddSheet.toggle()
                                        } label: {
                                                Image(systemName: "plus.circle.fill")
                                                        .font(.title2)
                                                        .foregroundStyle(.white)
                                        }
                                        .accessibilityLabel("Créer un nouvel événement")
                                }
                        }
                        .sheet(isPresented: $showAddSheet) {
                                AddEventView()
                        }
                        .onAppear {
                                viewModel.loadEventsIfNeeded()
                        }
                }
                .preferredColorScheme(.dark)
        }
}
