//
//  ImageStorageService.swift
//  Eventorias
//
//  Created by Perez William on 08/01/2026.
//

import Foundation
import FirebaseStorage

/// Struct pour transporter les infos après un upload
struct StorageUploadResult {
        let url: String
        let path: String
}

//MARK: Contrat
protocol ImageStorageServiceProtocol: Sendable {
        func uploadImage(data: Data, path: String) async throws -> StorageUploadResult
        func deleteImage(path: String) async
}

//MARK: Implementation
final class ImageStorageService: ImageStorageServiceProtocol {
        
        private let storage = Storage.storage()
        
        func uploadImage(data: Data, path: String) async throws -> StorageUploadResult {
                let fileRef = storage.reference().child(path)
                
                _ = try await fileRef.putDataAsync(data)
                
                let url = try await fileRef.downloadURL()
                
                return StorageUploadResult(url: url.absoluteString, path: path)
        }
        
        /// Supprime un fichier du Storage. Si le fichier n'existe pas, l'erreur est ignorée.
        func deleteImage(path: String) async {
                let fileRef = storage.reference().child(path)
                do {
                        try await fileRef.delete()
                        print("Image Storage supprimée : \(path)")
                } catch {
                        let nsError = error as NSError
                        if nsError.code == StorageErrorCode.objectNotFound.rawValue {
                                print("L'image n'existait déjà plus sur le serveur (404), on continue.")
                        } else {
                                print("Erreur Storage imprévue : \(error.localizedDescription)")
                        }
                }
        }
}
