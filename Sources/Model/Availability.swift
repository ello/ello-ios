////
///  Availability.swift
//

import SwiftyJSON


let AvailabilityVersion = 1

@objc(Availability)
final class Availability: Model {
    let isUsernameAvailable: Bool
    let isEmailAvailable: Bool
    let isInvitationCodeAvailable: Bool
    let usernameSuggestions: [String]
    let emailSuggestion: String

    init(isUsernameAvailable: Bool, isEmailAvailable: Bool, isInvitationCodeAvailable: Bool, usernameSuggestions: [String], emailSuggestion: String) {
        self.isUsernameAvailable = isUsernameAvailable
        self.isEmailAvailable = isEmailAvailable
        self.isInvitationCodeAvailable = isInvitationCodeAvailable
        self.usernameSuggestions = usernameSuggestions
        self.emailSuggestion = emailSuggestion
        super.init(version: AvailabilityVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        self.isUsernameAvailable = decoder.decodeKey("isUsernameAvailable")
        self.isEmailAvailable = decoder.decodeKey("isEmailAvailable")
        self.isInvitationCodeAvailable = decoder.decodeKey("isInvitationCodeAvailable")
        self.usernameSuggestions = decoder.decodeKey("usernameSuggestions")
        self.emailSuggestion = decoder.decodeKey("emailSuggestion")
        super.init(coder: coder)
    }

    class func fromJSON(_ data: [String: Any]) -> Availability {
        let json = JSON(data)

        return Availability(
            isUsernameAvailable: json["username"].boolValue,
            isEmailAvailable: json["email"].boolValue,
            isInvitationCodeAvailable: json["invitation_code"].boolValue,
            usernameSuggestions: json["suggestions"]["username"].arrayValue.map { $0.stringValue },
            emailSuggestion: json["suggestions"]["email"]["full"].stringValue)
    }
}
