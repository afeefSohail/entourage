// ProfileViewModel.swift — screen VM for the user's own profile
import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {

    var user: User = EntourageManager.shared.user
    var group: Group?
    var isLoading = false
    var errorMessage: String?

    private let userRepo  = UserRepository.shared
    private let groupRepo = GroupRepository.shared

    init() {
        group = EntourageManager.shared.myGroup
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        do {
            if let u = try await userRepo.getUser() {
                EntourageManager.shared.user = u
                user = u
            }
            if let g = try await groupRepo.myGroup() {
                EntourageManager.shared.myGroup = g
                group = g
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
