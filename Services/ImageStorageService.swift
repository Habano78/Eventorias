//
//  ImageStorageService.swift
//  Eventorias
//
//  Created by Perez William on 08/01/2026.
//

import Foundation
import FirebaseStorage

// MARK: - Protocol
protocol ImageStorageServiceProtocol: Sendable {
    func uploadImage(data: Data, path: String) async throws -> String
}

// MARK: Implementation
final class ImageStorageService: ImageStorageServiceProtocol {
    
    private let storage = Storage.storage()
    
    func uploadImage(data: Data, path: String) async throws -> String {
        let fileRef = storage.reference().child(path)
        _ = try await fileRef.putDataAsync(data)
        
        let url = try await fileRef.downloadURL()
        return url.absoluteString
    }
}
