import Foundation

enum ProfileCompletionStep: Equatable {
    case age       // gender or first_name missing → route to gender screen
    case birthday  // gender/name done but no DOB → route to birthday screen
    case photos
    case username
    case complete
}

extension User {

    var nextProfileStep: ProfileCompletionStep {
        if gender == nil || gender?.isEmpty == true { return .age }
        if first_name == nil || first_name?.isEmpty == true { return .age }
        if self.age == nil || self.age == 0 { return .birthday }
        if photos.isEmpty { return .photos }
        if let phone = phone_number, !phone.isEmpty {
            let defaultUsername = String(phone.dropFirst())
            if user_name == nil || user_name == defaultUsername || user_name?.isEmpty == true {
                return .username
            }
        }
        return .complete
    }

    var isProfileComplete: Bool { nextProfileStep == .complete }

    @available(*, deprecated, renamed: "nextProfileStep")
    func checkUserInfo() -> String {
        switch nextProfileStep {
        case .age:      return "Gender"
        case .birthday: return "Birthday"
        case .photos:   return "Photos"
        case .username: return "userName"
        case .complete: return "Main"
        }
    }
}
