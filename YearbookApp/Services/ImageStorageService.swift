//
//  ImageStorageService.swift
//  YearbookApp
//
//  Created by Mohamed Shahbain on 5/23/26.
//


import Foundation
import Cloudinary

/// Uploads images to Cloudinary using an unsigned upload preset.
/// Returns the secure URL of the uploaded image, which gets stored
/// in the Post document so the feed can display it.
final class ImageStorageService {

    /// Your Cloudinary cloud name. Safe to ship in client code.
    private let cloudName = "dqo3sou4o"

    /// The unsigned upload preset name configured in the Cloudinary
    /// console. The preset controls what's allowed (folder, file size,
    /// transformations) — so no secrets need to live in the app.
    private let uploadPreset = "mainmemories_unsigned"

    private lazy var cloudinary: CLDCloudinary = {
        let config = CLDConfiguration(cloudName: cloudName, secure: true)
        return CLDCloudinary(configuration: config)
    }()

    /// Upload a post image. Returns the https URL of the uploaded asset.
    func uploadPostImage(data: Data) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let params = CLDUploadRequestParams()
            // Cloudinary auto-generates a unique public ID by default,
            // so we don't have to worry about collisions.

            cloudinary.createUploader().upload(
                data: data,
                uploadPreset: uploadPreset,
                params: params,
                completionHandler: { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else if let url = result?.secureUrl {
                        continuation.resume(returning: url)
                    } else {
                        continuation.resume(throwing: NSError(
                            domain: "ImageStorageService",
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Upload returned no URL."]
                        ))
                    }
                }
            )
        }
    }
}