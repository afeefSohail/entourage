// EditProfileViewModel.swift — screen VM for editing the user's profile
import Foundation
import UIKit
import Observation

enum UsernameStatus: Equatable {
    case unchanged, tooShort, checking, available, taken
}

@Observable
@MainActor
final class EditProfileViewModel {

    var photos: [Photo] = []
    var firstName: String = ""
    var userName: String = "" {
        didSet {
            let cleaned = userName.lowercased().filter { $0.isLetter || $0.isNumber || $0 == "." || $0 == "_" }
            if cleaned != userName { userName = cleaned; return }
            if userName != oldValue { scheduleUsernameCheck() }
        }
    }
    var bio: String = ""
    var usernameStatus: UsernameStatus = .unchanged
    var isSaving = false
    var isUploading = false
    var errorMessage: String?

    static let bioLimit = 300

    private let repo = UserRepository.shared
    /// Exactly what the server has; sent back untouched when the username isn't edited.
    private let storedUserName: String
    /// The stored value as the field shows it (some seed data has a leading "@").
    private let originalUserName: String
    @ObservationIgnored private var checkTask: Task<Void, Never>?

    init() {
        let user = EntourageManager.shared.user
        photos = user.photos.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
        firstName = user.firstName ?? ""
        storedUserName = user.userName ?? ""
        originalUserName = storedUserName.lowercased().filter { $0.isLetter || $0.isNumber || $0 == "." || $0 == "_" }
        userName = originalUserName
        bio = user.bio ?? ""
        usernameStatus = .unchanged
    }

    var sortedPhotos: [Photo] { photos.sorted { ($0.order ?? 0) < ($1.order ?? 0) } }

    var trimmedName: String { firstName.trimmingCharacters(in: .whitespacesAndNewlines) }

    var canSave: Bool {
        guard trimmedName.count >= 2, !isSaving else { return false }
        return usernameStatus == .unchanged || usernameStatus == .available
    }

    private func scheduleUsernameCheck() {
        checkTask?.cancel()
        guard userName != originalUserName else { usernameStatus = .unchanged; return }
        guard userName.count >= 3 else { usernameStatus = .tooShort; return }
        usernameStatus = .checking
        let candidate = userName
        checkTask = Task {
            try? await Task.sleep(nanoseconds: 450_000_000)
            guard !Task.isCancelled else { return }
            let available = (try? await repo.checkUserNameAvailability(userName: candidate)) != nil
            guard !Task.isCancelled, candidate == userName else { return }
            usernameStatus = available ? .available : .taken
        }
    }

    /// Returns true when the profile was saved; on failure the shared user is restored.
    func save() async -> Bool {
        isSaving = true
        defer { isSaving = false }
        let manager = EntourageManager.shared
        let previous = (manager.user.firstName, manager.user.userName, manager.user.bio)
        manager.user.firstName = trimmedName
        manager.user.userName = usernameStatus == .unchanged ? storedUserName : userName
        manager.user.bio = String(bio.prefix(Self.bioLimit))
        do {
            _ = try await repo.editUserProfile(checkAge: false)
            return true
        } catch {
            (manager.user.firstName, manager.user.userName, manager.user.bio) = previous
            errorMessage = error.localizedDescription
            return false
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
