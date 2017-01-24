////
///  Availability.swift
//

import SwiftyJSON


let AvailabilityVersion = 1

@objc(Availability)
final class Availability: JSONAble {
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

    required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        self.isUsernameAvailable = decoder.decodeKey("isUsernameAvailable")
        self.isEmailAvailable = decoder.decodeKey("isEmailAvailable")
        self.isInvitationCodeAvailable = decoder.decodeKey("isInvitationCodeAvailable")
        self.usernameSuggestions = decoder.decodeKey("usernameSuggestions")
        self.emailSuggestion = decoder.decodeKey("emailSuggestion")
        super.init(coder: aDecoder)
    }
}

extension Availability {
    override class func fromJSON(_ data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let username = json["username"].boolValue
        let email = json["email"].boolValue
        let invitationCode = json["invitation_code"].boolValue
        let usernameSuggestions = json["suggestions"]["username"].arrayValue.map { $0.stringValue }
        let emailSuggestion = json["suggestions"]["email"]["full"].stringValue

        return Availability(isUsernameAvailable: username, isEmailAvailable: email, isInvitationCodeAvailable: invitationCode, usernameSuggestions: usernameSuggestions, emailSuggestion: emailSuggestion)
    }
}
