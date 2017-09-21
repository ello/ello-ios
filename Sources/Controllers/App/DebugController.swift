////
///  DebugController.swift
//

import SwiftyUserDefaults
import Crashlytics
import ImagePickerSheetController
import MessageUI


struct DebugSettings {
    static let useStaging = "UseStaging"
    static let deepLinkURL = "DebugServer.deepLinkURL"
}

enum DebugServer: String {
    static var fromDefaults: DebugServer? {
        guard
            !Globals.isTesting,
            let name = GroupDefaults[DebugSettings.useStaging].string,
            let server = DebugServer(rawValue: name)
        else { return nil }
        return server
    }

    case ninja = "Ninja"
    case stage1 = "Stage 1"
    case stage2 = "Stage 2"

    var apiKeys: APIKeys {
        switch self {
        case .ninja: return APIKeys.ninja
        case .stage1: return APIKeys.stage1
        case .stage2: return APIKeys.stage2
        }
    }
}

class DebugController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    fileprivate var retainer: UIViewController?

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

            let options: [DebugServer] = [.ninja, .stage1, .stage2]
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
                let user: User! = appController.currentUser
                appController.showOnboardingScreen(user)
            }
        }

        addAction(name: "Artist Invites preview") {
            appController.closeDebugController {
                let vc = ArtistInvitesViewController(usage: .loggedOut)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

        addAction(name: "Editorials preview") { [unowned self] in
            let vc = EditorialsViewController(usage: .loggedOut)
            self.navigationController?.pushViewController(vc, animated: true)
        }

        addAction(name: "Logout") {
            appController.closeDebugController {
                appController.userLoggedOut()
            }
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

                let okCancelAction = AlertAction(title: "", style: .okCancel) { _ in
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

        addAction(name: "Reset Tooltips for 2.0") {
            GroupDefaults[ElloTab.ToolTipsResetForTwoPointOhKey] = nil
            appController.closeDebugController()
        }

        addAction(name: "Crash the app") {
            Crashlytics.sharedInstance().crash()
        }

        addAction(name: "Debug Views") { [unowned self] in
            let vc = DebugViewsController()
            self.navigationController?.pushViewController(vc, animated: true)
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
