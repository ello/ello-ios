////
///  InviteService.swift
//

import Moya
import SwiftyJSON
import PromiseKit


struct InviteService {
    typealias FindSuccess = [(LocalPerson, User?)]

    func sendInvitations(_ emails: [String]) -> Promise<()> {
        return ElloProvider.shared.request(.invitations(emails: emails))
            .asVoid()
    }

    func invite(_ email: String) -> Promise<()> {
        return ElloProvider.shared.request(.inviteFriends(email: email))
            .asVoid()
    }

    func find(_ addressBook: AddressBookProtocol, currentUser: User?) -> Promise<FindSuccess> {
        var contacts = [String: [String]]()
        for person in addressBook.localPeople {
            contacts[person.identifier] = person.emails
        }

        return ElloProvider.shared.request(.findFriends(contacts: contacts))
            .then { data, _ -> FindSuccess in
                guard let data = data as? [User] else {
                    throw NSError.uncastableJSONAble()
                }

                let users = InviteService.filterUsers(data, currentUser: currentUser)
                let userIdentifiers = users.map { $0.identifiableBy ?? "" }
                let mixed: [(LocalPerson, User?)] = addressBook.localPeople.map {
                    if let index = userIdentifiers.index(of: $0.identifier) {
                        return ($0, users[index])
                    }
                    return ($0, .none)
                }
                return mixed
            }
    }

    static func filterUsers(_ users: [User], currentUser: User?) -> [User] {
        return users.filter { $0.identifiableBy != .none && $0.id != currentUser?.id }
    }

}
