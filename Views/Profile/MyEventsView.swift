//
//  MyEventsView.swift
//  Eventorias
//
//  Created by Perez William on 17/12/2025.
//

import SwiftUI
import FirebaseAuth

struct MyEventsView: View {
        
        //MARK: Properties
        @Environment(EventListViewModel.self) var viewModel
        @Environment(\.horizontalSizeClass) var sizeClass
        
        //MARK: Computed properties
        var myTickets: [Event] {
                guard let currentUserId = Auth.auth().currentUser?.uid else { return [] }
                
                return viewModel.events.filter { event in
                        event.attendees.contains(currentUserId)
                }
        }
        
        /// Configuration grille iPad
        let columns = [
                GridItem(.adaptive(minimum: 320), spacing: 20)
        ]
        
        //MARK: body
        var body: some View {
                NavigationStack {
                        ZStack {
                                
                                Color.black.ignoresSafeArea()
                                
                                if myTickets.isEmpty {
                                        
                                        VStack(spacing: 20) {
                                                Image(systemName: "ticket")
                                                        .font(.system(size: 60))
                                                        .foregroundStyle(.gray)
                                                        .accessibilityHidden(true)
                                                
                                                Text("Aucun ticket pour le moment")
                                                        .font(.headline)
                                                        .foregroundStyle(.white)
                                                
                                                Text("Explorez les événements et cliquez sur 'Je participe' !")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.gray)
                                                        .multilineTextAlignment(.center)
                                                        .padding(.horizontal)
                                        }
                                        .accessibilityElement(children: .combine)
                                } else {
                                        
                                        // Adaptation Ipad/Iphone
                                        if sizeClass == .regular {
                                                /// IPad
                                                ScrollView {
                                                        LazyVGrid(columns: columns, spacing: 20) {
                                                                ForEach(myTickets) { event in
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
                                                /// Iphone
                                                List {
                                                        ForEach(myTickets) { event in
                                                                NavigationLink(destination: EventDetailView(event: event)) {
                                                                        HStack(spacing: 15) {
                                                                                Image(event.category.assetName)
                                                                                        .resizable()
                                                                                        .aspectRatio(contentMode: .fill)
                                                                                        .frame(width: 60, height: 60)
                                                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                                                
                                                                                VStack(alignment: .leading, spacing: 5) {
                                                                                        Text(event.title)
                                                                                                .font(.headline)
                                                                                                .foregroundStyle(.white)
                                                                                        
                                                                                        Text(event.date.formatted(date: .abbreviated, time: .shortened))
                                                                                                .font(.caption)
                                                                                                .foregroundStyle(.gray)
                                                                                }
                                                                        }
                                                                        .padding(.vertical, 5)
                                                                }
                                                                .listRowBackground(Color.clear)
                                                                .listRowSeparatorTint(.gray.opacity(0.3))
                                                                .accessibilityElement(children: .ignore)
                                                                .accessibilityLabel("Ticket pour \(event.title), le \(event.date.formatted(date: .long, time: .shortened))")
                                                                .accessibilityHint("Double-tapez pour voir les détails")
                                                        }
                                                }
                                                .listStyle(.plain)
                                        }
                                }
                        }
                        .navigationTitle("Mes Tickets")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarColorScheme(.dark, for: .navigationBar)
                }
        }
}
