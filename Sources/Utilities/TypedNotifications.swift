////
///  TypedNotifications.swift
//
//  Thanks to objc.io http://www.objc.io/snippets/16.html
//  Find Here: https://gist.github.com/chriseidhof/9bf7280063db3a249fbe

struct TypedNotification<A> {
    let name: NSNotification.Name
    init(name: String) {
        self.name = NSNotification.Name(name)
    }
    init(name: NSNotification.Name) {
        self.name = name
    }
}

func postNotification<A>(_ note: TypedNotification<A>, value: A) {
    let userInfo = ["value": Box(value)]
    NotificationCenter.default.post(name: note.name, object: nil, userInfo: userInfo)
}

class NotificationObserver {
    let observer: NSObjectProtocol

    init<A>(notification: TypedNotification<A>, block aBlock: @escaping (A) -> Void) {
        observer = NotificationCenter.default.addObserver(
            forName: notification.name,
            object: nil,
            queue: nil
        ) { note in
            if let value = (note.userInfo?["value"] as? Box<A>)?.value {
                aBlock(value)
            }
            else {
                assert(false, "Couldn't understand user info")
            }
        }
    }

    func removeObserver() {
        NotificationCenter.default.removeObserver(observer)
    }

    deinit {
        removeObserver()
    }

}
