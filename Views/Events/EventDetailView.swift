//
//  EventDetailView.swift
//  Eventorias
//
//  Created by Perez William on 15/12/2025.
//

import SwiftUI
import MapKit // <--- Ajout nécessaire pour la vraie carte

struct EventDetailView: View {
        
        let event: Event
        
        @Environment(\.dismiss) var dismiss
        
        //MARK: body
        var body: some View {
                ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                                
                                // Image
                                Image(event.category.assetName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 300)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                
                                // Date/Heure/Avatar
                                HStack(alignment: .center) {
                                        VStack(alignment: .leading, spacing: 8) {
                                                /// Date
                                                HStack {
                                                        Image(systemName: "calendar")
                                                                .foregroundStyle(.white)
                                                        Text(event.date.formatted(.dateTime.year().month(.wide).day()))
                                                                .foregroundStyle(.white)
                                                }
                                                /// Heure
                                                HStack {
                                                        Image(systemName: "clock")
                                                                .foregroundStyle(.white)
                                                        
                                                        Text(event.date.formatted(date: .omitted, time: .shortened))
                                                                .foregroundStyle(.white)
                                                }
                                        }
                                        .font(.subheadline)
                                        
                                        Spacer()
                                        
                                        /// Avatar
                                        Image("Avatar (3)")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 60, height: 60)
                                                .clipShape(Circle())
                                                .shadow(radius: 5)
                                }
                                
                                // Description
                                Text(event.description)
                                        .font(.body)
                                        .foregroundStyle(.gray)
                                        .lineSpacing(5)
                                
                                Spacer()
                                
                                // Adresse + CARTE
                                HStack (alignment: .top, spacing: 15) {
                                        VStack(alignment: .leading, spacing: 5) {
                                                
                                                Text(event.location)
                                                        .font(.headline)
                                                        .foregroundStyle(.gray)
                                                        .fixedSize(horizontal: false, vertical: true)
                                        }
                                        .padding(.top, 8)
                                        Spacer()
                                        //.frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        //MAP
                                        Map(initialPosition: .region(MKCoordinateRegion(
                                                center: CLLocationCoordinate2D(latitude: 23.1136, longitude: -82.3666),
                                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        )))
                                        .frame(width: 140, height: 75)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .disabled(true)
                                }
                                
                                .padding()
                                
                                .padding(.bottom, 80)
                                
                        }
                        .padding()
                }
                .background(Color.black.ignoresSafeArea())
                .navigationBarBackButtonHidden(true)
                .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                                Button { dismiss() } label: {
                                        Image(systemName: "arrow.left")
                                                .foregroundStyle(.white)
                                                .fontWeight(.bold)
                                }
                        }
                        ToolbarItem(placement: .principal) {
                                Text(event.title)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                        }
                }
        }
}

//MARK: previw
#Preview {
        EventDetailView(event: Event(
                userId: "1",
                title: "Test Event",
                description: "No billion-dollar retraining. No complex fine-tuning. Just eight words that unlock creativity we thought was lost forever.​The paper comes from Stanford, Northeastern, and West Virginia University. The technique is called Verbalized Sampling. And it’s so stupidly simple that when I first tried it, I actually laughed out loud.",
                date: Date(),
                location: "123 Rue de l'Art, Quartier des Galeries, Paris, 75003, France",
                category: .charity
        ))
}
