////
///  HireViewController.swift
//

import PromiseKit


class HireViewController: BaseElloViewController {
    override func trackerName() -> String? {
        switch contactType {
        case .hire: return "Hire"
        case .collaborate: return "Collaborate"
        }
    }
    override func trackerProps() -> [String: Any]? {
        return ["username": user.username]
    }

    enum UserEmailType {
        case hire
        case collaborate
    }

    let user: User
    let contactType: UserEmailType
    private var _mockScreen: HireScreenProtocol?
    var screen: HireScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return _mockScreen ?? self.view as! HireScreen }
    }
    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

    required init(user: User, type: UserEmailType) {
        self.user = user
        self.contactType = type
        super.init(nibName: nil, bundle: nil)

        switch contactType {
        case .hire:
            title = InterfaceString.Hire.HireTitle(atName: user.atName)
        case .collaborate:
            title = InterfaceString.Hire.CollaborateTitle(atName: user.atName)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = HireScreen()
        screen.navigationBar.leftItems = [.back]
        screen.delegate = self
        screen.recipient = user.displayName
        self.view = screen
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        postNotification(StatusBarNotifications.statusBarVisibility, value: true)
        UIApplication.shared.statusBarStyle = .lightContent

        bottomBarController?.setNavigationBarsVisible(true, animated: false)

        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: self.keyboardWillShow)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: self.keyboardWillHide)
        screen.toggleKeyboard(visible: Keyboard.shared.isActive)
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

extension HireViewController: HireScreenDelegate {
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

        let endpoint: Promise<Void>
        switch contactType {
        case .hire:
            endpoint = HireService().hire(user: user, body: body)
        case .collaborate:
            endpoint = HireService().collaborate(user: user, body: body)
        }

        endpoint
            .then { _ -> Void in
                Tracker.shared.hiredUser(self.user)
                hireSuccess()
            }
            .catch { error in
                self.screen.hideSuccess()
                let alertController = AlertViewController(confirmation: InterfaceString.GenericError)
                self.present(alertController, animated: true, completion: nil)
            }
    }
}
