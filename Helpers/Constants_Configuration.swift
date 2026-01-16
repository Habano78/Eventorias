//
//  Constants_Configuration.swift
//  Eventorias
//
//  Created by Perez William on 16/01/2026.
//

import Foundation
import SwiftUI

enum UIConfig {
    
    // Mise en page
    enum Layout {
        
        /// Grille standard pour iPad et écrans larges (320px min)
        static let gridColumns = [
            GridItem(.adaptive(minimum: 320), spacing: 20)
        ]
        
        /// Marge standard pour les vues
        static let defaultPadding: CGFloat = 20
    }
    
}
