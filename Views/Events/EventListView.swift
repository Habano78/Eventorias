//
//  EventListView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

struct EventListView: View {
        
        // MARK: - Properties
        @Environment(EventListViewModel.self) var viewModel
        @Environment(\.horizontalSizeClass) var sizeClass
        
        @State private var showAddSheet = false
        @State private var searchText = ""
        
        
        // MARK: - Filtrage
        var filteredEvents: [Event] {
                
                var result = viewModel.events
                
                if !searchText.isEmpty {
                        result = result.filter { event in
                                event.title.localizedCaseInsensitiveContains(searchText) ||
                                event.location.localizedCaseInsensitiveContains(searchText)
                        }
                }
                if let category = viewModel.selectedCategory {
                        result = result.filter { $0.category == category }
                }
                return result.sorted { $0.date < $1.date }
        }
        
        // MARK: - Body
        var body: some View {
                NavigationStack {
                        VStack(spacing: 0) {
                                categoryFilterBar
                                
                                if viewModel.isLoading && viewModel.events.isEmpty {
                                        Spacer()
                                        ProgressView().tint(.white)
                                        Spacer()
                                } else if filteredEvents.isEmpty {
                                        Spacer()
                                        ContentUnavailableView(
                                                "Aucun événement",
                                                systemImage: "magnifyingglass",
                                                description: Text("Essayez de modifier votre recherche ou vos filtres.")
                                        )
                                        .foregroundStyle(.white)
                                        Spacer()
                                } else {
                                        eventsDisplay
                                }
                        }
                        .background(Color.black.ignoresSafeArea())
                        .navigationTitle("Événements")
                        .searchable(text: $searchText, prompt: "Rechercher...")
                        .toolbar {
                                ToolbarItem(placement: .primaryAction) {
                                        Button { showAddSheet.toggle() } label: {
                                                Image(systemName: "plus.circle.fill")
                                                        .font(.title2)
                                                        .foregroundStyle(.white)
                                        }
                                }
                        }
                        .overlay(alignment: .top) {
                                if viewModel.showSuccessToast {
                                        ToastView(message: viewModel.successMessage)
                                                .padding(.top, 10)
                                                .transition(.move(edge: .top).combined(with: .opacity))
                                }
                        }
                        .animation(.spring(), value: viewModel.showSuccessToast)
                        .sheet(isPresented: $showAddSheet) {
                                AddEventView()
                        }
                        .task {
                                await viewModel.loadEventsIfNeeded()
                        }
                }
        }
        
        // MARK: - Helper Subviews
        
        private var categoryFilterBar: some View {
                ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                                FilterButton(title: "Tout", isSelected: viewModel.selectedCategory == nil) {
                                        withAnimation { viewModel.selectedCategory = nil }
                                }
                                ForEach(EventCategory.allCases) { category in
                                        FilterButton(title: category.rawValue, isSelected: viewModel.selectedCategory == category) {
                                                withAnimation { viewModel.selectedCategory = category }
                                        }
                                }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                }
                .background(Color.black)
        }
        
        private var eventsDisplay: some View {
                Group {
                        if sizeClass == .regular {
                                ScrollView {
                                        LazyVGrid(columns: UIConfig.Layout.gridColumns, spacing: 20) {
                                                ForEach(filteredEvents) { event in
                                                        NavigationLink(destination: EventDetailView(event: event)) {
                                                                EventRowView(event: event)
                                                                        .frame(height: 120)
                                                        }
                                                        .buttonStyle(PlainButtonStyle())
                                                }
                                        }
                                        .padding()
                                }
                        } else {
                                List {
                                        ForEach(filteredEvents) { event in
                                                NavigationLink(destination: EventDetailView(event: event)) {
                                                        EventRowView(event: event)
                                                }
                                                .listRowBackground(Color.clear)
                                                .listRowSeparator(.hidden)
                                        }
                                }
                                .listStyle(.plain)
                                .refreshable {
                                        await viewModel.fetchEvents()
                                }
                        }
                }
        }
}

// MARK: COMPOSANTS

// Bouton de filtre
struct FilterButton: View {
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
                Button(action: action) {
                        Text(title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(isSelected ? Color.blue : Color(white: 0.2))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                                .overlay(
                                        Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                }
                .accessibilityLabel("Filtrer par catégorie \(title)")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
}

// Message de succès
struct ToastView: View {
        let message: String
        var body: some View {
                Text(message)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .font(.subheadline.bold())
                        .cornerRadius(20)
                        .shadow(radius: 5)
        }
}
