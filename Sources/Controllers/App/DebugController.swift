////
///  DebugController.swift
//

import SwiftyUserDefaults
import Crashlytics
import ImagePickerSheetController

class DebugController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
    var actions = [(String, BasicBlock)]()

    private func addAction(name: String, block: @escaping BasicBlock) {
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
        addAction(name: "Logout") {
            appController.closeTodoController() {
                appController.userLoggedOut()
            }
        }
        addAction(name: "Debug Tracking") {
            if Tracker.shared.overrideAgent is DebugAgent {
                let vc = DebugTrackingController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                appController.closeTodoController() {
                    Tracker.shared.overrideAgent = DebugAgent()
                    let alertController = AlertViewController(error: "Debug tracking is on")
                    appController.present(alertController, animated: true, completion: nil)
                }
            }
        }
        addAction(name: "Deep Linking") {
            appController.closeTodoController() {
                let alertController = AlertViewController()

                let urlAction = AlertAction(title: "Enter URL", style: .urlInput)
                alertController.addAction(urlAction)

                let okCancelAction = AlertAction(title: "", style: .okCancel) { _ in
                    delay(0.5) {
                        if let urlString = alertController.actionInputs.safeValue(0) {
                            appController.navigateToDeepLink(urlString)
                        }
                    }
                }
                alertController.addAction(okCancelAction)

                appController.present(alertController, animated: true, completion: nil)
            }
        }
        addAction(name: "ImagePickerSheetController") {
            let controller = ImagePickerSheetController(mediaType: .imageAndVideo)
            controller.addAction(ImagePickerAction(title: InterfaceString.ImagePicker.TakePhoto, handler: { _ in }))
            controller.addAction(ImagePickerAction(title: InterfaceString.ImagePicker.PhotoLibrary, secondaryTitle: { NSString.localizedStringWithFormat(InterfaceString.ImagePicker.AddImagesTemplate as NSString, $0) as String}, handler: { _ in }, secondaryHandler: { _, numberOfPhotos in }))
            controller.addAction(ImagePickerAction(title: InterfaceString.Cancel, style: .cancel, handler: { _ in }))

            self.present(controller, animated: true, completion: nil)
        }
        addAction(name: "Invalidate refresh token (use user credentials)") {
            var token = AuthToken()
            token.token = "nil"
            token.refreshToken = "nil"
            appController.closeTodoController()

            let profileService = ProfileService()
            profileService.loadCurrentUser(success: { _ in }, failure: { _ in })
            profileService.loadCurrentUser(success: { _ in }, failure: { _ in })
            nextTick {
                profileService.loadCurrentUser(success: { _ in }, failure: { _ in })
            }
        }
        addAction(name: "Invalidate token completely (logout)") {
            var token = AuthToken()
            token.token = "nil"
            token.refreshToken = "nil"
            token.username = "ello@ello.co"
            token.password = "this is definitely NOT my password"
            appController.closeTodoController()

            let profileService = ProfileService()
            profileService.loadCurrentUser(success: { _ in print("success 1") }, failure: { _ in print("failure 1") })
            profileService.loadCurrentUser(success: { _ in print("success 2") }, failure: { _ in print("failure 2") })
            nextTick {
                profileService.loadCurrentUser(success: { _ in print("success 3") }, failure: { _ in print("failure 3") })
            }
        }
        addAction(name: "Reset Tab bar Tooltips") {
            GroupDefaults[ElloTab.discover.narrationDefaultKey] = nil
            GroupDefaults[ElloTab.notifications.narrationDefaultKey] = nil
            GroupDefaults[ElloTab.stream.narrationDefaultKey] = nil
            GroupDefaults[ElloTab.profile.narrationDefaultKey] = nil
            GroupDefaults[ElloTab.omnibar.narrationDefaultKey] = nil
        }
        addAction(name: "Reset Intro") {
            GroupDefaults["IntroDisplayed"] = nil
        }
        addAction(name: "Crash the app") {
            Crashlytics.sharedInstance().crash()
        }

        addAction(name: "Debug Views") { [unowned self] in
            let vc = DebugViewsController()
            self.navigationController?.pushViewController(vc, animated: true)
        }

        addAction(name: "Show Notification") {
            appController.closeTodoController() {
                PushNotificationController.sharedController.receivedNotification(UIApplication.shared, userInfo: [
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
            PushNotificationController.sharedController.permissionDenied = false
            PushNotificationController.sharedController.needsPermission = true
            if let alert = PushNotificationController.sharedController.requestPushAccessIfNeeded() {
                appController.closeTodoController() {
                    appController.present(alert, animated: true, completion: .none)
                }
            }
        }

        for (comment, message) in getlog() {
            actions.append((comment, {
                let alertController = AlertViewController(message: message)
                let okCancelAction = AlertAction(title: "", style: .okCancel) { _ in }
                alertController.addAction(okCancelAction)
                appController.present(alertController, animated: true, completion: nil)
            }))
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
