//
//  MockImageStorageService.swift
//  EventoriasTests
//
//  Created by Perez William on 08/01/2026.
//

import Foundation
import UIKit
@testable import Eventorias

@MainActor
final class MockImageStorageService: ImageStorageServiceProtocol {
        
        nonisolated(unsafe) var shouldReturnError = false
        
        nonisolated func uploadImage(data: Data, path: String) async throws -> String {
                if shouldReturnError { throw NSError(domain: "Storage", code: 500) }
                return "https://mock-storage.com/image.jpg"
        }
}
