// GroupManagementViewModel.swift
import Foundation
import Observation

@Observable
@MainActor
final class GroupManagementViewModel {

    var group: Group?
    var isLoading = false
    var errorMessage: String?
    var showLeaveConfirm = false

    private let groupRepo = GroupRepository.shared

    init() {
        group = EntourageManager.shared.myGroup
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            if let g = try await groupRepo.myGroup() {
                EntourageManager.shared.myGroup = g
                group = g
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func leaveGroup(onSuccess: @escaping () -> Void) async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await groupRepo.leaveGroup()
            EntourageManager.shared.myGroup = nil
            group = nil
            onSuccess()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
