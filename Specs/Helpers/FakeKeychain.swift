@testable import Ello


class FakeKeychain: KeychainType {
    var pushToken: Data?
    var authToken: String?
    var refreshAuthToken: String?
    var authTokenExpires: Date?
    var authTokenType: String?
    var isPasswordBased: Bool?
    var username: String?
    var password: String?
    var isStaff: Bool?
}
