// SettingsViewModel.swift — screen VM for the settings screen
import Foundation
import Observation

@Observable
@MainActor
final class SettingsViewModel {

    var setting: Setting
    var isSaving  = false
    var errorMessage: String?

    private let repo = UserRepository.shared
    private let preSetting: Setting
    private let preGender: String

    init() {
        let s = EntourageManager.shared.setting ?? Setting()
        self.setting   = s
        self.preSetting = s.copy()
        self.preGender  = EntourageManager.shared.user.gender ?? ""
    }

    var filterText: String {
        let user = EntourageManager.shared.user
        if setting.everyone    == true { return "Everyone" }
        if setting.female_only == true { return "Females" }
        if setting.male_only   == true { return "Males" }
        return user.gender == "male" ? "Females" : user.gender == "female" ? "Males" : "Everyone"
    }

    var buildVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return "Build \(v)"
    }

    var phoneNumber: String { EntourageManager.shared.user.phoneNumber ?? "" }

    var genderDisplay: String { (EntourageManager.shared.user.gender ?? "").capitalizingFirstLetter() }

    var blockedCount: Int { setting.block_member_count ?? 0 }

    func loadIfNeeded() async {
        guard EntourageManager.shared.setting == nil else { return }
        if let s = try? await repo.getUserSettings() {
            setting = s
        }
    }

    func save() async {
        let changed = Setting.checkSettingUpdateion(
            previousGender: preGender,
            preSetting: preSetting,
            NewSetting: setting
        )
        guard changed else { return }
        isSaving = true
        do {
            EntourageManager.shared.setting = setting
            _ = try await repo.updateSettings()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}
