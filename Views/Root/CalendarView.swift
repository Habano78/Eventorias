//
//  CalendarView.swift
//  Eventorias
//
//  Created by Perez William on 28/12/2025.
//

import SwiftUI

struct CalendarView: View {
        
        //MARK: Properties
        @Environment(EventListViewModel.self) var viewModel
        @State private var selectedDate = Date()
        
        //MARK: Body
        var body: some View {
                NavigationStack {
                        VStack(spacing: 0) {
                                
                                // Calendrier
                                DatePicker("Choisir une date", selection: $selectedDate, displayedComponents: .date)
                                        .datePickerStyle(.graphical)
                                        .padding()
                                        .background(Color(white: 0.1))
                                        .cornerRadius(15)
                                        .padding()
                                
                                Divider().background(Color.gray)
                                
                                // Liste des événements
                                VStack(alignment: .leading) {
                                        Text("Événements du \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                                                .font(.headline)
                                                .foregroundStyle(.gray)
                                                .padding(.horizontal)
                                                .padding(.top, 10)
                                        
                                        let eventsOfDay = viewModel.events.filter { event in
                                                Calendar.current.isDate(event.date, inSameDayAs: selectedDate)
                                        }
                                        
                                        if eventsOfDay.isEmpty {
                                                Spacer()
                                                ContentUnavailableView(
                                                        "Aucun événement",
                                                        systemImage: "calendar.badge.exclamationmark",
                                                        description: Text("Rien de prévu pour cette journée.")
                                                )
                                                Spacer()
                                        } else {
                                                List(eventsOfDay) { event in
                                                        NavigationLink(destination: EventDetailView(event: event)) {
                                                                EventRowView(event: event)
                                                        }
                                                        .listRowBackground(Color.clear)
                                                        .listRowSeparator(.hidden)
                                                }
                                                .listStyle(.plain)
                                        }
                                }
                        }
                        .background(Color.black.ignoresSafeArea())
                        .navigationTitle("Calendrier")
                        .navigationBarTitleDisplayMode(.inline)
                }
        }
}

#Preview {
        CalendarView()
                .environment(EventListViewModel())
                .preferredColorScheme(.dark)
}
