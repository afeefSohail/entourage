// EditProfileViewModel.swift — screen VM for editing the user's profile
import Foundation
import UIKit
import Observation

@Observable
@MainActor
final class EditProfileViewModel {

    var photos: [Photo] = []
    var bio: String = ""
    var isSaving = false
    var isUploading = false
    var errorMessage: String?

    private let repo = UserRepository.shared

    init() {
        let user = EntourageManager.shared.user
        photos = user.photos.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
        bio = user.bio ?? ""
    }

    var sortedPhotos: [Photo] { photos.sorted { ($0.order ?? 0) < ($1.order ?? 0) } }

    func save() async {
        isSaving = true
        defer { isSaving = false }
        do {
            EntourageManager.shared.user.bio = bio
            _ = try await repo.editUserProfile(checkAge: false)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func uploadPhoto(_ imageData: Data) async {
        let order = photos.count
        let isPrimary = photos.isEmpty
        isUploading = true
        defer { isUploading = false }
        do {
            if let user = try await repo.uploadPhoto(image: imageData, isPrimary: isPrimary, order: order) {
                EntourageManager.shared.user = user
                photos = user.photos.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deletePhoto(_ photo: Photo) async {
        do {
            try await repo.deletePhoto(photoId: photo.id)
            photos.removeAll { $0.id == photo.id }
            EntourageManager.shared.user.photos = photos
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func movePhoto(from source: IndexSet, to destination: Int) {
        photos.move(fromOffsets: source, toOffset: destination)
        // Persist the new order
        Task {
            for (idx, photo) in photos.enumerated() {
                let isPrimary = (idx == 0)
                try? await repo.setOrderPhoto(photoId: photo.id, order: idx, isPrimary: isPrimary)
                photos[idx].order = idx
                photos[idx].is_primary = isPrimary
            }
            EntourageManager.shared.user.photos = photos
        }
    }
}
