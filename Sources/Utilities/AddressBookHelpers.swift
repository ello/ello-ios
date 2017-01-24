////
///  AddressBookHelpers.swift
//

struct AddressBookHelpers {
    static func searchFilter(_ text: String) -> ((StreamCellItem) -> Bool)? {
        if text.characters.count < 2 { return nil }
        return { item in
            if let user = item.jsonable as? User {
                return user.name.contains(text) || user.username.contains(text)
            }
            else if let person = item.jsonable as? LocalPerson {
                return person.name.contains(text) || person.emails.any { $0.contains(text) }
            }
            return true
        }
    }

    static func process(_ contacts: [(LocalPerson, User?)], currentUser: User?) -> [StreamCellItem] {
        var foundItems = [StreamCellItem]()
        var inviteItems = [StreamCellItem]()
        let currentUserEmail = currentUser?.profile?.email
        for contact in contacts {
            let (person, user): (LocalPerson, User?) = contact
            if let user = user {
                foundItems.append(StreamCellItem(jsonable: user, type: .userListItem))
            }
            else {
                if currentUserEmail == nil || !person.emails.contains(currentUserEmail!) {
                    inviteItems.append(StreamCellItem(jsonable: person, type: .inviteFriends))
                }
            }
        }
        foundItems.sort { ($0.jsonable as! User).username.lowercased() < ($1.jsonable as! User).username.lowercased() }
        inviteItems.sort { ($0.jsonable as! LocalPerson).name.lowercased() < ($1.jsonable as! LocalPerson).name.lowercased() }
        return foundItems + inviteItems
    }
}
