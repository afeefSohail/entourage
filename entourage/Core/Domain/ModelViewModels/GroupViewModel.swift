// GroupViewModel.swift — presentation wrapper for a single Group model
import Foundation
import UIKit

struct GroupViewModel {

    let group: Group

    init(_ group: Group) {
        self.group = group
    }

    var displayName: String { group.myGroupName() }

    var memberCount: Int { group.users.count }

    var memberCountText: String { "\(memberCount) people" }

    var distanceText: String { group.distance ?? "0 Miles" }

    var isActive: Bool { group.status == "active" }

    var memberCountImageName: String { "memberNum\(memberCount)" }

    var primaryMembers: [User] { Array(group.users.prefix(4)) }
}
