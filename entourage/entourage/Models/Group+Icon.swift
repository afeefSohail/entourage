import Foundation

enum GroupGenderComposition {
    case allFemale(count: Int)
    case majorityFemale(count: Int)
    case allMale(count: Int)
    case majorityMale(count: Int)
    case mixed(count: Int)
    case unknown(count: Int)

    var iconName: String {
        switch self {
        case .allFemale(let c), .majorityFemale(let c): return "\(c)F"
        case .allMale(let c), .majorityMale(let c):     return "\(c)M"
        case .mixed(let c):                              return "\(c)Mix"
        case .unknown(let c):                            return "\(c)?"
        }
    }
}

extension Group {

    var genderComposition: GroupGenderComposition {
        let genderCounts = users.reduce(into: [String: Int]()) { counts, user in
            if let gender = user.gender?.lowercased() {
                counts[gender, default: 0] += 1
            }
        }
        let total = users.count
        guard total > 0 else { return .unknown(count: 0) }
        let femaleCount = genderCounts["female"] ?? 0
        let maleCount   = genderCounts["male"]   ?? 0

        if femaleCount == total          { return .allFemale(count: total) }
        if maleCount == total            { return .allMale(count: total) }
        if femaleCount > total / 2       { return .majorityFemale(count: total) }
        if maleCount > total / 2         { return .majorityMale(count: total) }
        if femaleCount > 0 && maleCount > 0 { return .mixed(count: total) }
        return .unknown(count: total)
    }

    var iconName: String { genderComposition.iconName }

    @available(*, deprecated, renamed: "iconName")
    func getGroupIconName() -> String { iconName }
}
