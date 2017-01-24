////
///  JWT.swift
//

import JWTDecode


public struct JWT {
    public static func refresh() {
        var authToken = AuthToken()
        guard let accessToken = authToken.token else { return }

        do {
            let jwt = try decode(jwt: accessToken)
            guard
                let data = jwt.body["data"] as? [String: Any],
                let staff = data["is_staff"] as? Bool
                else { return }
            authToken.isStaff = staff
        }
        catch {
            print("Unable to decode JWT")
        }
    }
}
