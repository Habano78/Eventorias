//
//  EventDetailView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI
import MapKit

struct EventDetailView: View {
        
        // MARK: properties
        let event: Event
        
        @Environment(\.dismiss) var dismiss
        @Environment(EventListViewModel.self) var eventListViewModel
        @Environment(\.horizontalSizeClass) var sizeClass
        
        @State private var showEditSheet = false
        @State private var showDeleteAlert = false
        
        //MARK: Computed Properties
        var isParticipating: Bool {
                guard let currentUserId = eventListViewModel.currentUserId else { return false }
                if let liveEvent = eventListViewModel.events.first(where: { $0.id == event.id }) {
                        return liveEvent.attendees.contains(currentUserId)
                }
                return false
        }
        
        var attendeesCount: Int {
                if let liveEvent = eventListViewModel.events.first(where: { $0.id == event.id }) {
                        return liveEvent.attendees.count
                }
                return event.attendees.count
        }
        
        var shareMessage: String {
                return """
        Je t'invite à l'événement : \(event.title) !
        Lieu : \(event.location)
        Date : \(event.date.formatted(date: .long, time: .shortened))
        Rejoins-nous sur Eventorias !
        """
        }
        
        // MARK: body
        var body: some View {
                ScrollView {
                        // Adaptation Ipad/Iphone
                        if sizeClass == .regular {
                                HStack(alignment: .top, spacing: 30) {
                                        VStack(spacing: 20) {
                                                mainImageSection
                                                mapSection
                                        }
                                        .frame(maxWidth: .infinity)
                                        
                                        VStack(alignment: .leading, spacing: 20) {
                                                headerInfoSection
                                                Divider().background(Color.gray)
                                                descriptionSection
                                                actionSection
                                        }
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(30)
                                
                        } else {
                                // IPHONE
                                VStack(alignment: .leading, spacing: 20) {
                                        mainImageSection
                                        headerInfoSection
                                        descriptionSection
                                        actionSection
                                        mapSection
                                }
                                .padding()
                        }
                }
                .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                                ShareLink(item: shareMessage) {
                                        Image(systemName: "square.and.arrow.up").foregroundStyle(.blue)
                                }
                                .accessibilityLabel("Partager l'événement")
                        }
                        
                        if eventListViewModel.isOwner(of: event) {
                                
                                ToolbarItem(placement: .topBarTrailing) {
                                        Menu {
                                                /// Modifier
                                                Button {
                                                        showEditSheet.toggle()
                                                } label: {
                                                        Label("Modifier", systemImage: "pencil")
                                                }
                                                
                                                Text("aqui no va nada")
                                                /// Supprimer
                                                Button(role: .destructive) {
                                                        showDeleteAlert = true
                                                } label: {
                                                        Label("Supprimer", systemImage: "trash")
                                                }
                                                
                                        } label: {
                                                Image(systemName: "ellipsis.circle")
                                        }
                                }
                        }
                }
                .sheet(isPresented: $showEditSheet) {
                        EditEventView(event: event)
                }
                .background(Color.black.ignoresSafeArea())
                .navigationBarBackButtonHidden(false)
                .navigationTitle(event.title)
                .navigationBarTitleDisplayMode(.inline)
        }
        
        
        // MARK: Subviews
        
        private var mainImageSection: some View {
                Group {
                        if let imageURL = event.imageURL, let url = URL(string: imageURL) {
                                AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty: ZStack { Color(white: 0.1); ProgressView() }
                                        case .success(let image): image.resizable().aspectRatio(contentMode: .fill)
                                        case .failure: Image(event.category.assetName).resizable().aspectRatio(contentMode: .fill)
                                        @unknown default: EmptyView()
                                        }
                                }
                        } else {
                                Image(event.category.assetName).resizable().aspectRatio(contentMode: .fill)
                        }
                }
                .frame(height: sizeClass == .regular ? 400 : 300)
                .frame(minWidth: 0, maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .accessibilityLabel("Photo de l'événement \(event.title)")
                .accessibilityAddTraits(.isImage)
        }
        
        private var headerInfoSection: some View {
                HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                        Image(systemName: "calendar")
                                        Text(event.date.formatted(.dateTime.year().month(.wide).day()))
                                }
                                .foregroundStyle(.white)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Date : \(event.date.formatted(date: .long, time: .omitted))")
                                
                                HStack {
                                        Image(systemName: "clock")
                                        Text(event.date.formatted(date: .omitted, time: .shortened))
                                }
                                .foregroundStyle(.white)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Heure : \(event.date.formatted(date: .omitted, time: .shortened))")
                        }
                        .font(sizeClass == .regular ? .title3 : .subheadline)
                        
                        Spacer()
                        
                        Image("Avatar (3)")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                                .accessibilityLabel("Avatar de l'organisateur")
                }
        }
        
        private var descriptionSection: some View {
                Text(event.description)
                        .font(.body)
                        .foregroundStyle(.gray)
                        .lineSpacing(5)
        }
        
        private var actionSection: some View {
                HStack(spacing: 0) {
                        HStack(spacing: 4) {
                                Image(systemName: "person.2.fill").font(.subheadline)
                                Text("\(attendeesCount)").font(.headline).fontWeight(.bold)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(white: 0.2))
                        .clipShape(Capsule())
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(attendeesCount) participants")
                        
                        Text(" participants")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .padding(.leading, 8)
                                .accessibilityHidden(true)
                        
                        Spacer()
                        
                        Button {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                Task {
                                        await eventListViewModel.toggleParticipation(event: event)
                                }
                        } label: {
                                HStack(spacing: 6) {
                                        Image(systemName: isParticipating ? "checkmark.circle.fill" : "ticket.fill")
                                                .font(.title3)
                                        Text(isParticipating ? "Inscrit(e)" : "Participer")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                }
                                .font(.subheadline)
                                .frame(width: 140, height: 45)
                                .background(isParticipating ? Color(white: 0.2) : Color.blue)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                                .shadow(color: isParticipating ? .clear : .blue.opacity(0.4), radius: 10, x: 0, y: 5)
                        }
                        .padding(.vertical, 5)
                        .accessibilityLabel(isParticipating ? "Se désinscrire" : "S'inscrire")
                        .accessibilityHint(isParticipating ? "Annuler votre venue" : "Rejoindre l'événement")
                        .accessibilityAddTraits(isParticipating ? .isSelected : [])
                }
                .padding(.vertical, 5)
        }
        
        private var mapSection: some View {
                HStack (alignment: .top, spacing: 15) {
                        VStack(alignment: .leading, spacing: 1) {
                                Text(event.location)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel("Adresse : \(event.location)")
                        
                        Map(initialPosition: .region(MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude),
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        ))) {
                                Marker(event.location, coordinate: CLLocationCoordinate2D(latitude: event.latitude, longitude: event.longitude))
                        }
                        .frame(width: 130, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .disabled(true)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Carte centrée sur \(event.location)")
                }
                .padding(.bottom, 80)
        }
}
