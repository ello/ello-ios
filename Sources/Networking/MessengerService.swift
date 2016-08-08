////
///  MessengerService.swift
//

import Moya
import SwiftyJSON


public struct MessengerService {

    public init(){}

    public func createConversation(users: [User]) {
        let endpoint: ElloAPI = .CreateConversation(users: users)

        ElloProvider.shared.elloRequest(
            endpoint,
            success: { (data, responseConfig) in
                print("successfully created a conversation")
            },
            failure: { (error, statusCode) in
                print("FAILED to creat a conversation")
            })
    }
}
