import Foundation

enum ProfileCompletionStep: Equatable {
    case gender       // gender missing → route to gender screen
    case name       // first or last name missing → route to first name screen
    case birthday  // name done but no DOB → route to birthday screen
    case photos
    case username
    case complete
}

extension User {

    var nextProfileStep: ProfileCompletionStep {
        if gender == nil || gender?.isEmpty == true { return .gender }
        if firstName == nil || firstName?.isEmpty == true { return .name }
        if lastName == nil || lastName?.isEmpty == true { return .name }
        if age == nil || age == 0 { return .birthday }
        if photos.isEmpty { return .photos }
        if let phone = phoneNumber, !phone.isEmpty {
            let defaultUsername = String(phone.dropFirst())
            if userName == nil || userName == defaultUsername || userName?.isEmpty == true {
                return .username
            }
        }
        return .complete
    }

    var isProfileComplete: Bool { nextProfileStep == .complete }

    @available(*, deprecated, renamed: "nextProfileStep")
    func checkUserInfo() -> String {
        switch nextProfileStep {
        case .gender:      return "Gender"
        case .name: return "First Name"
        case .birthday: return "Birthday"
        case .photos:   return "Photos"
        case .username: return "userName"
        case .complete: return "Main"
        }
    }
}
