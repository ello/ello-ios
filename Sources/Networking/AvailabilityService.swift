////
///  AvailabilityService.swift
//

import Moya
import SwiftyJSON
import PromiseKit


struct AvailabilityService {

    func usernameAvailability(_ username: String) -> Promise<Availability> {
        return availability(["username": username])
    }

    func emailAvailability(_ email: String) -> Promise<Availability> {
        return availability(["email": email])
    }

    func availability(_ content: [String: String]) -> Promise<Availability> {
        let endpoint = ElloAPI.availability(content: content)
        return ElloProvider.shared.request(endpoint)
            .then { response -> Availability in
                guard let data = response.0 as? Availability else {
                    throw NSError.uncastableJSONAble()
                }
                return data
            }
    }
}
