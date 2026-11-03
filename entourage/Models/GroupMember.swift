import Foundation

enum MembershipStatus {
    case confirmed
    case pending
}

struct GroupMember {
    let user: User
    let status: MembershipStatus

    var id: Int { user.id }
    var isActive: Bool  { status == .confirmed }
    var isPending: Bool { status == .pending }
}

extension Group {

    var allMembers: [GroupMember] {
        users.map { GroupMember(user: $0, status: .confirmed) }
    }

    @available(*, deprecated, message: "Use users directly or allMembers instead")
    func allGroupMember() -> [User] {
        users.forEach { $0.isMember = true }
        return users
    }
}
