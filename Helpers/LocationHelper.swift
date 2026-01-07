//
//  LocationHelper.swift
//  Eventorias
//
//  Created by Perez William on 01/01/2026.
//

import Foundation
import MapKit

struct LocationHelper {
    
    /// Transforme une adresse (String) en coordonnées GPS
    static func getCoordinates(from address: String) async throws -> CLLocationCoordinate2D {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address
     
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        if let item = response.mapItems.first {
            return item.location.coordinate
        } else {
            throw URLError(.badURL)
        }
    }
}
