////
///  HireViewController.swift
//

import FutureKit


class HireViewController: BaseElloViewController {
    override func trackerName() -> String? {
        switch contactType {
        case .hire: return "Hire"
        case .collaborate: return "Collaborate"
        }
    }
    override func trackerProps() -> [String: AnyObject]? {
        return ["username": user.username as AnyObject]
    }

    enum UserEmailType {
        case hire
        case collaborate
    }

    let user: User
    let contactType: UserEmailType
    var mockScreen: HireScreenProtocol?
    var screen: HireScreenProtocol { return mockScreen ?? (self.view as! HireScreenProtocol) }
    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

    required init(user: User, type: UserEmailType) {
        self.user = user
        self.contactType = type
        super.init(nibName: nil, bundle: nil)

        switch contactType {
        case .hire:
            title = NSString.localizedStringWithFormat(InterfaceString.Hire.HireTitleTemplate as NSString, user.atName) as String
        case .collaborate:
            title = NSString.localizedStringWithFormat(InterfaceString.Hire.CollaborateTitleTemplate as NSString, user.atName) as String
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let item = UIBarButtonItem.backChevron(withController: self)
        elloNavigationItem.leftBarButtonItems = [item]
        elloNavigationItem.fixNavBarItemPadding()

        let screen = HireScreen()
        screen.navigationItem = elloNavigationItem
        screen.delegate = self
        screen.recipient = user.displayName
        self.view = screen
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        postNotification(StatusBarNotifications.statusBarShouldHide, value: false)
        UIApplication.shared.statusBarStyle = .lightContent

        elloTabBarController?.tabBarHidden = false

        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: self.keyboardWillShow)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: self.keyboardWillHide)
        screen.toggleKeyboard(visible: Keyboard.shared.active)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        keyboardWillShowObserver?.removeObserver()
        keyboardWillShowObserver = nil
        keyboardWillHideObserver?.removeObserver()
        keyboardWillHideObserver = nil
    }

    func keyboardWillShow(_ keyboard: Keyboard) {
        screen.toggleKeyboard(visible: true)
    }

    func keyboardWillHide(_ keyboard: Keyboard) {
        screen.toggleKeyboard(visible: false)
    }

}

extension HireViewController: HireDelegate {
    func submit(body: String) {
        guard !body.isEmpty else { return }

        self.screen.showSuccess()
        let hireSuccess = after(2) {
            _ = self.navigationController?.popViewController(animated: true)
            delay(DefaultAppleAnimationDuration) {
                self.screen.hideSuccess()
            }
        }
        // this ensures a minimum 3 second display of the success screen
        delay(3) {
            hireSuccess()
        }

        let endpoint: Future<Void>
        switch contactType {
        case .hire:
            endpoint = HireService().hire(user: user, body: body)
        case .collaborate:
            endpoint = HireService().collaborate(user: user, body: body)
        }

        endpoint
            .onSuccess { _ in
                Tracker.shared.hiredUser(self.user)
                hireSuccess()
            }
            .onFail { error in
                self.screen.hideSuccess()
                let alertController = AlertViewController(error: InterfaceString.GenericError)
                self.present(alertController, animated: true, completion: nil)
            }
    }
}
