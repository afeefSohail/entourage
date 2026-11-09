import Foundation

enum ProfileCompletionStep: Equatable {
    case age
    case photos
    case username
    case complete
}

extension User {

    var nextProfileStep: ProfileCompletionStep {
        if age == nil || age == 0 { return .age }
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
        case .photos:   return "Photos"
        case .username: return "userName"
        case .complete: return "Main"
        }
    }
}
