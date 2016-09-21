////
///  DebugTodoController.swift
//

#if DEBUG

import SwiftyUserDefaults
import Crashlytics
import ImagePickerSheetController

class DebugTodoController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
    var actions = [(String, BasicBlock)]()

    private func addAction(name: String, block: BasicBlock) {
        actions.append((name, block))
    }

    var marketingVersion = ""
    var buildVersion = ""

    override func viewDidLoad() {
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            marketingVersion = version.stringByReplacingOccurrencesOfString(".", withString: "-", options: [], range: nil)
        }

        if let bundleVersion = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            buildVersion = bundleVersion.stringByReplacingOccurrencesOfString(".", withString: "-", options: [], range: nil)
        }

        let appController = UIApplication.sharedApplication().keyWindow!.rootViewController as! AppViewController
        addAction("Logout") {
            appController.closeTodoController() {
                appController.userLoggedOut()
            }
        }
        addAction("Deep Linking") {
            appController.closeTodoController() {
                let alertController = AlertViewController()

                let urlAction = AlertAction(title: "Enter URL", style: .URLInput)
                alertController.addAction(urlAction)

                let okCancelAction = AlertAction(title: "", style: .OKCancel) { _ in
                    delay(0.5) {
                        if let urlString = alertController.actionInputs.safeValue(0) {
                            appController.navigateToDeepLink(urlString)
                        }
                    }
                }
                alertController.addAction(okCancelAction)

                appController.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        addAction("ImagePickerSheetController") {
            let controller = ImagePickerSheetController(mediaType: .ImageAndVideo)
            controller.addAction(ImagePickerAction(title: InterfaceString.ImagePicker.TakePhoto, handler: { _ in }))
            controller.addAction(ImagePickerAction(title: InterfaceString.ImagePicker.PhotoLibrary, secondaryTitle: { NSString.localizedStringWithFormat(InterfaceString.ImagePicker.AddImagesTemplate, $0) as String}, handler: { _ in }, secondaryHandler: { _, numberOfPhotos in }))
            controller.addAction(ImagePickerAction(title: InterfaceString.Cancel, style: .Cancel, handler: { _ in }))

            self.presentViewController(controller, animated: true, completion: nil)
        }
        addAction("Invalidate refresh token (use user credentials)") {
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
        addAction("Invalidate token completely (logout)") {
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
        addAction("Reset Tab bar Tooltips") {
            GroupDefaults[ElloTab.Discover.narrationDefaultKey] = nil
            GroupDefaults[ElloTab.Notifications.narrationDefaultKey] = nil
            GroupDefaults[ElloTab.Stream.narrationDefaultKey] = nil
            GroupDefaults[ElloTab.Profile.narrationDefaultKey] = nil
            GroupDefaults[ElloTab.Omnibar.narrationDefaultKey] = nil
        }
        addAction("Reset Intro") {
            GroupDefaults["IntroDisplayed"] = nil
        }
        addAction("Crash the app") {
            Crashlytics.sharedInstance().crash()
        }

        addAction("Debug Views") { [unowned self] in
            let vc = DebugViewsController()
            self.navigationController?.pushViewController(vc, animated: true)
        }

        addAction("Show Notification") {
            appController.closeTodoController() {
                PushNotificationController.sharedController.receivedNotification(UIApplication.sharedApplication(), userInfo: [
                    "application_target": "notifications/posts/6178",
                    "aps": [
                        "alert": ["body": "Hello, Ello!"]
                    ]
                ])
            }
        }

        addAction("Show Rate Prompt") {
            Rate.sharedRate.prompt()
        }

        addAction("Show Push Notification Alert") {
            PushNotificationController.sharedController.permissionDenied = false
            PushNotificationController.sharedController.needsPermission = true
            if let alert = PushNotificationController.sharedController.requestPushAccessIfNeeded() {
                appController.closeTodoController() {
                    appController.presentViewController(alert, animated: true, completion: .None)
                }
            }
        }

        for message in getlog() {
            actions.append((message, {}))
        }

        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "todo")
        view.addSubview(tableView)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actions.count
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Debugging Actions"
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath path: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Action")
        if let label = cell.textLabel, action = actions.safeValue(path.row) {
            label.font = UIFont.defaultBoldFont()
            label.text = action.0
        }
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath path: NSIndexPath) {
        tableView.deselectRowAtIndexPath(path, animated: true)
        if let action = actions.safeValue(path.row) {
            action.1()
        }
    }

}
#endif
