//
//  EventListView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI

enum EventSortOption: String, CaseIterable, Identifiable {
        case dateAscending = "Plus proche"
        case dateDescending = "Plus lointain"
        case titleAZ = "A-Z"
        case popularity = "Popularité"
        
        var id: String { self.rawValue }
}

struct EventListView: View {
        
        // MARK: dependence
        @Environment(EventListViewModel.self) var eventListViewModel
        
        // MARK: properties
        @State private var searchText = ""
        @State private var showAddEventSheet = false
        @State private var selectedSortOption: EventSortOption = .dateAscending
        
        var filteredAndSortedEvents: [Event] {
                var result = eventListViewModel.events
                
                //Filtrage par Catégorie (via ViewModel)
                if let category = eventListViewModel.selectedCategory {
                        result = result.filter { $0.category == category }
                }
                
                //Filtrage par Recherche (Search Text)
                if !searchText.isEmpty {
                        result = result.filter { event in
                                event.title.localizedCaseInsensitiveContains(searchText)
                        }
                }
                
                // 4. Tri
                return result.sorted { event1, event2 in
                        switch selectedSortOption {
                        case .dateAscending: return event1.date < event2.date
                        case .dateDescending: return event1.date > event2.date
                        case .titleAZ: return event1.title < event2.title
                        case .popularity: return event1.attendees.count > event2.attendees.count
                        }
                }
        }
        
        // MARK: body
        var body: some View {
                NavigationStack {
                        
                        ZStack(alignment: .bottomTrailing) {
                                
                                VStack(spacing: 0) {
                                        
                                        HStack {
                                                Image(systemName: "magnifyingglass")
                                                        .foregroundStyle(.gray)
                                                
                                                TextField("Search", text: $searchText)
                                                        .foregroundStyle(.white)
                                                        .tint(.white)
                                                
                                                if !searchText.isEmpty {
                                                        Button {
                                                                searchText = ""
                                                        } label: {
                                                                Image(systemName: "xmark.circle.fill")
                                                                        .foregroundStyle(.gray)
                                                        }
                                                }
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                        .background(Color(white: 0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 25))
                                        .padding(.horizontal)
                                        .padding(.top, 5)
                                        
                                        // BOUTON SORTING
                                        HStack {
                                                Menu {
                                                        Picker("Trier par", selection: $selectedSortOption) {
                                                                ForEach(EventSortOption.allCases) { option in
                                                                        Text(option.rawValue).tag(option)
                                                                }
                                                        }
                                                } label: {
                                                        HStack(spacing: 6) {
                                                                Image(systemName: "arrow.up.arrow.down")
                                                                        .font(.footnote)
                                                                Text("Trier")
                                                                        .font(.subheadline)
                                                                        .fontWeight(.medium)
                                                        }
                                                        .padding(.vertical, 8)
                                                        .padding(.horizontal, 16)
                                                        .background(Color(white: 0.25))
                                                        .foregroundStyle(.white)
                                                        .clipShape(Capsule())
                                                }
                                                
                                                Spacer()
                                        }
                                        .padding(.horizontal)
                                        .padding(.top, 10)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: 10) {
                                                        
                                                        Button(action: {
                                                                withAnimation {
                                                                        eventListViewModel.selectedCategory = nil
                                                                }
                                                        }) {
                                                                Text("Tout")
                                                                        .font(.subheadline)
                                                                        .fontWeight(.semibold)
                                                                        .padding(.horizontal, 16)
                                                                        .padding(.vertical, 8)
                                                                        .background(eventListViewModel.selectedCategory == nil ? Color.blue : Color(white: 0.25))
                                                                        .foregroundColor(.white)
                                                                        .cornerRadius(20)
                                                        }
                                                        
                                                        // Boutons des Catégories
                                                        ForEach(EventCategory.allCases, id: \.self) { category in
                                                                Button(action: {
                                                                        withAnimation {
                                                                                if eventListViewModel.selectedCategory == category {
                                                                                        eventListViewModel.selectedCategory = nil
                                                                                } else {
                                                                                        eventListViewModel.selectedCategory = category
                                                                                }
                                                                        }
                                                                }) {
                                                                        Text(category.rawValue.capitalized)
                                                                                .font(.subheadline)
                                                                                .fontWeight(.semibold)
                                                                                .padding(.horizontal, 16)
                                                                                .padding(.vertical, 8)
                                                                                .background(eventListViewModel.selectedCategory == category ? Color.blue : Color(white: 0.25))
                                                                                .foregroundColor(.white)
                                                                                .cornerRadius(20)
                                                                }
                                                        }
                                                }
                                                .padding(.horizontal)
                                        }
                                        .padding(.bottom, 10)
                                        
                                        // LISTE
                                        Group {
                                                if filteredAndSortedEvents.isEmpty {
                                                        VStack(spacing: 20) {
                                                                Spacer()
                                                                Image(systemName: searchText.isEmpty ? "calendar.badge.plus" : "magnifyingglass")
                                                                        .font(.system(size: 50))
                                                                        .foregroundStyle(.gray)
                                                                
                                                                Text(searchText.isEmpty ? "Aucun événement" : "Aucun résultat")
                                                                        .font(.headline)
                                                                        .foregroundStyle(.gray)
                                                                Spacer()
                                                        }
                                                        .frame(maxWidth: .infinity)
                                                        
                                                } else {
                                                        List {
                                                                ForEach(filteredAndSortedEvents) { event in
                                                                        ZStack {
                                                                                NavigationLink(destination: EventDetailView(event: event)) {
                                                                                        EmptyView()
                                                                                }
                                                                                .opacity(0)
                                                                                
                                                                                EventRowView(event: event)
                                                                        }
                                                                        .listRowSeparator(.hidden)
                                                                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 4, trailing: 16))
                                                                        .listRowBackground(Color.black)
                                                                }
                                                                .onDelete(perform: deleteEvent)
                                                        }
                                                        .listStyle(.plain)
                                                        .scrollContentBackground(.hidden)
                                                }
                                        }
                                }
                                
                                // BOUTON FLOTTANT
                                Button {
                                        showAddEventSheet.toggle()
                                } label: {
                                        Image("Button - Add new event")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 40, height: 50)
                                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
                                }
                                .padding()
                                .padding(.bottom, 10)
                        }
                        // Opt
                        .task {
                                eventListViewModel.loadEventsIfNeeded()
                        }
                        .refreshable {
                                await eventListViewModel.fetchEvents()
                        }
                        // --------------------------------------
                        .toolbar(.hidden, for: .navigationBar)
                        .background(Color.black.ignoresSafeArea())
                        .sheet(isPresented: $showAddEventSheet) {
                                AddEventView()
                        }
                }
                .preferredColorScheme(.dark)
        }
        
        // MARK: Helper Methods
        
        private func deleteEvent(at offsets: IndexSet) {
                let eventsToDelete = offsets.map { filteredAndSortedEvents[$0] }
                for event in eventsToDelete {
                        Task {
                                eventListViewModel.deleteEvent(withId: event.id)
                        }
                }
        }
}

#Preview {
        EventListView()
                .environment(EventListViewModel())
}
