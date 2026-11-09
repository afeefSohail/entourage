import Foundation

enum GroupNameStyle {
    case `default`        // "Sarah and 2 others"
    case compact          // "Sarah & John"
    case detailed         // "Sarah, John and Mike"
    case withFriendsLabel // "Sarah & 2 Friends"

    var separator: String {
        switch self {
        case .compact, .withFriendsLabel: return "&"
        default: return "and"
        }
    }
}

extension Group {

    var otherMembers: [User] {
        users.filter { $0.id != EntourageManager.shared.user.id }
    }

    func displayName(style: GroupNameStyle = .default) -> String {
        let members = otherMembers
        guard !members.isEmpty else { return name ?? "Empty Group" }
        let firstNames = members.compactMap { $0.first_name }.filter { !$0.isEmpty }
        guard !firstNames.isEmpty else { return name ?? "Group" }

        switch (members.count, style) {
        case (1, _):
            return firstNames[0]
        case (2, .detailed):
            return "\(firstNames[0]) and \(firstNames[1])"
        case (2, .compact), (2, .withFriendsLabel):
            return "\(firstNames[0]) & \(firstNames[1])"
        case (2, _):
            return "\(firstNames[0]) and \(firstNames[1])"
        case (3, .detailed):
            return "\(firstNames[0]), \(firstNames[1]) and \(firstNames[2])"
        case (3, .compact):
            return "\(firstNames[0]), \(firstNames[1]) & \(firstNames[2])"
        case (let count, .withFriendsLabel) where count > 1:
            let others = count - 1
            return "\(firstNames[0]) & \(others) \(others == 1 ? "Friend" : "Friends")"
        case (let count, _) where count > 1:
            let others = count - 1
            return "\(firstNames[0]) \(style.separator) \(others) \(others == 1 ? "other" : "others")"
        default:
            return name ?? "Group"
        }
    }

    @available(*, deprecated, renamed: "displayName()")
    func matcherGroupName() -> String { displayName(style: .default) }

    @available(*, deprecated, renamed: "displayName(style:)")
    func otherGroupName() -> String { displayName(style: .compact) }

    @available(*, deprecated, renamed: "displayName(style:)")
    func cardsGroupName() -> String { displayName(style: .withFriendsLabel) }

    @available(*, deprecated, renamed: "displayName(style:)")
    func myGroupName() -> String { displayName(style: .detailed) }

    @available(*, deprecated, renamed: "displayName(style:)")
    func matchGroupName() -> String { displayName(style: .compact) }
}
