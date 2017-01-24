////
///  InviteService.swift
//

import Moya
import SwiftyJSON

typealias InviteFriendsSuccessCompletion = () -> Void
typealias FindFriendsSuccessCompletion = ([(LocalPerson, User?)]) -> Void

struct InviteService {

    init(){}

    func invite(_ contact: String, success: @escaping InviteFriendsSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        ElloProvider.shared.elloRequest(ElloAPI.inviteFriends(contact: contact),
            success: { _ in success() },
            failure: failure)
    }

    func find(_ addressBook: AddressBookProtocol, currentUser: User?, success: @escaping FindFriendsSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        var contacts = [String: [String]]()
        for person in addressBook.localPeople {
            contacts[person.identifier] = person.emails
        }

        ElloProvider.shared.elloRequest(ElloAPI.findFriends(contacts: contacts),
            success: { (data, responseConfig) in
                if let data = data as? [User] {
                    let users = InviteService.filterUsers(data, currentUser: currentUser)
                    let userIdentifiers = users.map { $0.identifiableBy ?? "" }
                    let mixed: [(LocalPerson, User?)] = addressBook.localPeople.map {
                        if let index = userIdentifiers.index(of: $0.identifier) {
                            return ($0, users[index])
                        }
                        return ($0, .none)
                    }

                    success(mixed)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            }, failure: failure)
    }

    static func filterUsers(_ users: [User], currentUser: User?) -> [User] {
        return users.filter { $0.identifiableBy != .none && $0.id != currentUser?.id }
    }

}
