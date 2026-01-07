//
//  MyEventsView.swift
//  Eventorias
//
//  Created by Perez William on 17/12/2025.
//

//
//  MyTicketsView.swift
//  Eventorias
//
//  Created by Perez William on 17/12/2025.
//

import SwiftUI
import FirebaseAuth

struct MyEventsView: View {
        
        //MARK: Properties
        @Environment(EventListViewModel.self) var viewModel
        
        
        //MARK: Computed properties
        var myTickets: [Event] {
                guard let currentUserId = Auth.auth().currentUser?.uid else { return [] }
                
                return viewModel.events.filter { event in
                        event.attendees.contains(currentUserId)
                }
        }
        
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
                                                Text("Aucun ticket pour le moment")
                                                        .font(.headline)
                                                        .foregroundStyle(.white)
                                                Text("Explorez les événements et cliquez sur 'Je participe' !")
                                                        .font(.subheadline)
                                                        .foregroundStyle(.gray)
                                                        .multilineTextAlignment(.center)
                                                        .padding(.horizontal)
                                        }
                                } else {
                                        List {
                                                ForEach(myTickets) { event in
                                                        
                                                        NavigationLink(destination: EventDetailView(event: event)) {
                                                                
                                                                HStack(spacing: 15) {
                                                                        // Image miniature
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
                                                }
                                        }
                                        .listStyle(.plain)
                                }
                        }
                        .navigationTitle("Mes Tickets")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarColorScheme(.dark, for: .navigationBar)
                }
        }
}
