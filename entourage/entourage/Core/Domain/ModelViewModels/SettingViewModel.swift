// SettingViewModel.swift — presentation wrapper for a single Setting model
import Foundation

struct SettingViewModel {

    let setting: Setting

    init(_ setting: Setting) {
        self.setting = setting
    }

    var ageRangeText: String {
        let min = setting.min_age ?? 18
        let max = setting.max_age ?? 42
        return "\(min)–\(max)"
    }

    var distanceText: String {
        let miles = setting.max_distace ?? 50
        return "\(miles) mi"
    }

    var groupSizeText: String {
        let count = setting.group_member_count ?? 3
        return "\(count) people"
    }

    var filterText: String {
        if setting.male_only == true   { return "Men only" }
        if setting.female_only == true { return "Women only" }
        return "Everyone"
    }

    var notificationSummary: String {
        var enabled: [String] = []
        if setting.general    == true { enabled.append("General") }
        if setting.friendship == true { enabled.append("Friends") }
        if setting.match      == true { enabled.append("Matches") }
        if setting.group      == true { enabled.append("Groups") }
        if setting.chat       == true { enabled.append("Chat") }
        return enabled.isEmpty ? "None" : enabled.joined(separator: ", ")
    }

    var areNotificationsEnabled: Bool {
        setting.general == true ||
        setting.friendship == true ||
        setting.match == true ||
        setting.group == true ||
        setting.chat == true
    }
}
