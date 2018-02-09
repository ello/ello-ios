////
///  DebugController.swift
//

import SwiftyUserDefaults
import ImagePickerSheetController
import MessageUI


class DebugController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var retainer: UIViewController?

    let tableView = UITableView()
    var actions = [(String, Block)]()

    private func addAction(name: String, block: @escaping Block) {
        actions.append((name, block))
    }

    var marketingVersion = ""
    var buildVersion = ""

    override func viewDidLoad() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            marketingVersion = version.replacingOccurrences(of: ".", with: "-")
        }

        if let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildVersion = bundleVersion.replacingOccurrences(of: ".", with: "-")
        }

        let appController = UIApplication.shared.keyWindow!.rootViewController as! AppViewController
        let debugServer = DebugServer.fromDefaults

        addAction(name: "Server: using \(debugServer?.rawValue ?? "Production")") {
            let alertController = AlertViewController(message: "What server do you want to use:")

            let option = AlertAction(title: "Production", style: .dark) { _ in
                GroupDefaults[DebugSettings.useStaging] = nil
                postNotification(AuthenticationNotifications.userLoggedOut, value: ())
                exit(0)
            }
            alertController.addAction(option)

            let options: [DebugServer] = [.ninja, .stage1, .stage2, .rainbow]
            for option in options {
                let action = AlertAction(title: option.rawValue, style: .dark) { _ in
                    GroupDefaults[DebugSettings.useStaging] = option.rawValue
                    postNotification(AuthenticationNotifications.userLoggedOut, value: ())
                    exit(0)
                }
                alertController.addAction(action)
            }

            appController.present(alertController, animated: true, completion: nil)
        }

        addAction(name: "Share via SMS") {
            self.retainer = self
            appController.closeDebugController {
                guard MFMessageComposeViewController.canSendText() else { return }

                let message = InterfaceString.Friends.SMSMessage

                let messageController = MFMessageComposeViewController()
                messageController.messageComposeDelegate = self
                messageController.body = message

                appController.present(messageController, animated: true, completion: nil)
            }
        }

        addAction(name: "Show Onboarding") {
            appController.closeDebugController {
                guard let user = appController.currentUser else { return }
                user.onboardingVersion = nil
                appController.showOnboardingScreen(user)
            }
        }

        addAction(name: "Show Creator Type") {
            appController.closeDebugController {
                guard let user = appController.currentUser else { return }
                user.onboardingVersion = Onboarding.minCreatorTypeVersion
                appController.showOnboardingScreen(user)
            }
        }

        addAction(name: "Logout") {
            appController.closeDebugController {
                appController.userLoggedOut()
            }
        }

        addAction(name: "Test auth token - refresh") {
            var token = AuthToken()
            token.token = ""
            appController.closeDebugController()
        }

        addAction(name: "Test auth token - u/p") {
            var token = AuthToken()
            token.token = ""
            token.refreshToken = ""
            appController.closeDebugController()
        }

        addAction(name: "Debug Tracking") {
            if Tracker.shared.overrideAgent is DebugAgent {
                let vc = DebugTrackingController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                appController.closeDebugController {
                    Tracker.shared.overrideAgent = DebugAgent()
                    let alertController = AlertViewController(error: "Debug tracking is on")
                    appController.present(alertController, animated: true, completion: nil)
                }
            }
        }

        addAction(name: "Deep Linking") {
            appController.closeDebugController {
                let alertController = AlertViewController()

                let initial = GroupDefaults[DebugSettings.deepLinkURL].string ?? "https://ello.co/"
                let urlAction = AlertAction(title: "Enter URL", initial: initial, style: .urlInput)
                alertController.addAction(urlAction)

                let okCancelAction = AlertAction(style: .okCancel) { _ in
                    delay(0.5) {
                        if let urlString = alertController.actionInputs.safeValue(0),
                            !urlString.isEmpty
                        {
                            GroupDefaults[DebugSettings.deepLinkURL] = urlString
                            appController.navigateToDeepLink(urlString)
                        }
                    }
                }
                alertController.addAction(okCancelAction)

                appController.present(alertController, animated: true, completion: nil)
            }
        }

        addAction(name: "Show Following Dot") {
            postNotification(NewContentNotifications.newFollowingContent, value: ())
            appController.closeDebugController()
        }

        addAction(name: "Show Notification Dot") {
            postNotification(NewContentNotifications.newNotifications, value: ())
            appController.closeDebugController()
        }

        addAction(name: "Reset Tab bar Tooltips") {
            ElloTab.resetToolTips()
            appController.closeDebugController()
        }

        addAction(name: "Show Notification") {
            appController.closeDebugController {
                PushNotificationController.shared.receivedNotification(UIApplication.shared, action: nil, userInfo: [
                    "application_target": "notifications/posts/6178",
                    "aps": [
                        "alert": ["body": "Hello, Ello!"]
                    ]
                ])
            }
        }

        addAction(name: "Show Rate Prompt") {
            Rate.sharedRate.prompt()
        }

        addAction(name: "Show Push Notification Alert") {
            PushNotificationController.shared.permissionDenied = false
            PushNotificationController.shared.needsPermission = true
            appController.closeDebugController {
                PushNotificationController.shared.requestPushAccessIfNeeded(appController)
            }
        }

        for (comment, message) in getlog() {
            addAction(name: comment) {
                UIPasteboard.general.string = message

                let alertController = AlertViewController(error: "Copied\n\n\(message)")
                appController.present(alertController, animated: true, completion: nil)
            }
        }

        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Action")
        view.addSubview(tableView)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Debugging Actions"
    }

    func tableView(_ tableView: UITableView, cellForRowAt path: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Action")
        if let label = cell.textLabel, let action = actions.safeValue(path.row) {
            label.font = UIFont.defaultBoldFont()
            label.text = action.0
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt path: IndexPath) {
        tableView.deselectRow(at: path, animated: true)
        if let action = actions.safeValue(path.row) {
            action.1()
        }
    }

}

extension DebugController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        guard let viewController = controller.presentingViewController else {
            self.retainer = nil
            return
        }

        viewController.dismiss(animated: true) {
            self.retainer = nil
        }
    }
}
