//
//  PhotoSaver.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/23/26.
//


import Foundation
import UIKit
import Photos

/// Downloads a remote image and saves it to the user's Photos library.
/// Uses the Photos framework's "add only" path so it doesn't need
/// full library read access.
enum PhotoSaver {

    enum SaveError: Error, LocalizedError {
        case invalidURL
        case downloadFailed
        case permissionDenied
        case saveFailed

        var errorDescription: String? {
            switch self {
            case .invalidURL:        "That image URL is invalid."
            case .downloadFailed:    "Couldn't download the image."
            case .permissionDenied:  "Photos access was denied."
            case .saveFailed:        "Couldn't save the photo."
            }
        }
    }

    /// Download from a URL, then save to Photos.
    static func save(remoteURL: String) async throws {
        guard let url = URL(string: remoteURL) else { throw SaveError.invalidURL }

        // 1. Download the image bytes.
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else { throw SaveError.downloadFailed }

        // 2. Make sure we have add-permission.
        let status = await requestAddOnlyAuthorization()
        guard status == .authorized || status == .limited else {
            throw SaveError.permissionDenied
        }

        // 3. Write to the library.
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: error ?? SaveError.saveFailed)
                }
            }
        }
    }

    /// Wraps the callback-based permission API in async/await.
    private static func requestAddOnlyAuthorization() async -> PHAuthorizationStatus {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
    }
}