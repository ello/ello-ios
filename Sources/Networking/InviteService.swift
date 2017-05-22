////
///  InviteService.swift
//

import Moya
import SwiftyJSON
import FutureKit


struct InviteService {
    typealias FindSuccess = [(LocalPerson, User?)]

    init(){}

    func invitations(_ emails: [String]) -> Future<()> {
        let promise = Promise<()>()
        ElloProvider.shared.elloRequest(ElloAPI.invitations(emails: emails),
            success: { _ in
                promise.completeWithSuccess(())
            },
            failure: { error, _ in
                promise.completeWithFail(error)
            })
        return promise.future
    }

    func invite(_ email: String) -> Future<()> {
        let promise = Promise<()>()
        ElloProvider.shared.elloRequest(ElloAPI.inviteFriends(email: email),
            success: { _ in
                promise.completeWithSuccess(())
            },
            failure: { error, _ in
                promise.completeWithFail(error)
            })
        return promise.future
    }

    func find(_ addressBook: AddressBookProtocol, currentUser: User?) -> Future<FindSuccess> {
        var contacts = [String: [String]]()
        for person in addressBook.localPeople {
            contacts[person.identifier] = person.emails
        }

        let promise = Promise<FindSuccess>()
        ElloProvider.shared.elloRequest(ElloAPI.findFriends(contacts: contacts),
            success: { (data, responseConfig) in
                guard let data = data as? [User] else {
                    let error = NSError.uncastableJSONAble()
                    promise.completeWithFail(error)
                    return
                }

                let users = InviteService.filterUsers(data, currentUser: currentUser)
                let userIdentifiers = users.map { $0.identifiableBy ?? "" }
                let mixed: [(LocalPerson, User?)] = addressBook.localPeople.map {
                    if let index = userIdentifiers.index(of: $0.identifier) {
                        return ($0, users[index])
                    }
                    return ($0, .none)
                }

                promise.completeWithSuccess(mixed)
            }, failure: { error, _ in
                promise.completeWithFail(error)
            })
        return promise.future
    }

    static func filterUsers(_ users: [User], currentUser: User?) -> [User] {
        return users.filter { $0.identifiableBy != .none && $0.id != currentUser?.id }
    }

}
