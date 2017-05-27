////
///  InviteService.swift
//

import Moya
import SwiftyJSON
import PromiseKit


struct InviteService {
    typealias FindSuccess = [(LocalPerson, User?)]

    init(){}

    func sendInvitations(_ emails: [String]) -> Promise<()> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(ElloAPI.invitations(emails: emails),
                success: { _ in
                    fulfill(())
                },
                failure: { error, _ in
                    reject(error)
                })
        }
    }

    func invite(_ email: String) -> Promise<()> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(ElloAPI.inviteFriends(email: email),
                success: { _ in
                    fulfill(())
                },
                failure: { error, _ in
                    reject(error)
                })
        }
    }

    func find(_ addressBook: AddressBookProtocol, currentUser: User?) -> Promise<FindSuccess> {
        var contacts = [String: [String]]()
        for person in addressBook.localPeople {
            contacts[person.identifier] = person.emails
        }

        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(ElloAPI.findFriends(contacts: contacts),
                success: { (data, responseConfig) in
                    guard let data = data as? [User] else {
                        let error = NSError.uncastableJSONAble()
                        reject(error)
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

                    fulfill(mixed)
                }, failure: { error, _ in
                    reject(error)
                })
        }
    }

    static func filterUsers(_ users: [User], currentUser: User?) -> [User] {
        return users.filter { $0.identifiableBy != .none && $0.id != currentUser?.id }
    }

}
