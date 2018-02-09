////
///  AddressBookController.swift
//

import Contacts
import Result
import MessageUI


typealias Completion = (Result<AddressBook, AddressBookError>) -> Void

struct AddressBookController {
    static func promptForAddressBookAccess(fromController controller: UIViewController, completion: @escaping Completion, cancelCompletion: @escaping Block = {}) {
        switch AddressBookController.authenticationStatus() {
        case .authorized:
            if MFMessageComposeViewController.canSendText() {
                promptForAccess(controller, completion: completion, cancelCompletion: cancelCompletion)
            }
            else {
                proceedWithImport(completion)
            }
        case .notDetermined:
            promptForAccess(controller, completion: completion, cancelCompletion: cancelCompletion)
        case .denied:
            displayAddressBookAlert(controller, message: InterfaceString.Friends.AccessDenied, completion: completion)
        case .restricted:
            displayAddressBookAlert(controller, message: InterfaceString.Friends.AccessRestricted, completion: completion)
        }
    }
}

extension AddressBookController {

    private static func promptForAccess(_ controller: UIViewController, completion: @escaping Completion, cancelCompletion: @escaping Block = {}) {
        let alertController = AlertViewController()

        let title = AlertAction(title: InterfaceString.Friends.ImportPermissionTitle, style: .title)
        alertController.addAction(title)

        let subtitle = AlertAction(title: InterfaceString.Friends.ImportPermissionSubtitle, style: .subtitle)
        alertController.addAction(subtitle)

        let message = AlertAction(title: InterfaceString.Friends.ImportPermissionPrompt, style: .message)
        alertController.addAction(message)

        if MFMessageComposeViewController.canSendText() {
            let smsMessage = InterfaceString.Friends.ImportSMS
            var smsAction = AlertAction(title: smsMessage, style: .green) { action in
                let message = InterfaceString.Friends.SMSMessage

                let messageController = MFMessageComposeViewController()
                messageComposer = MessageComposerDelegate()
                messageController.messageComposeDelegate = messageComposer
                messageController.body = message

                controller.present(messageController, animated: true, completion: nil)
                cancelCompletion()
            }
            smsAction.waitForDismiss = true
            alertController.addAction(smsAction)
        }

        let importMessage = InterfaceString.Friends.ImportAllow
        var proceedAction = AlertAction(title: importMessage, style: .green) { action in
            Tracker.shared.importContactsInitiated()
            self.proceedWithImport(completion)
        }
        proceedAction.waitForDismiss = true
        alertController.addAction(proceedAction)

        let cancelMessage = InterfaceString.Friends.ImportNotNow
        let cancelAction = AlertAction(title: cancelMessage, style: .roundedGrayFill) { _ in
            Tracker.shared.importContactsDenied()
            cancelCompletion()
        }
        alertController.addAction(cancelAction)

        controller.present(alertController, animated: true, completion: nil)
    }

    private static func proceedWithImport(_ completion: @escaping Completion) {
        Tracker.shared.addressBookAccessed()
        AddressBookController.getAddressBook { result in
            completion(result)
        }
    }

    private static func displayAddressBookAlert(_ controller: UIViewController, message: String, completion: @escaping Completion) {
        let alertController = AlertViewController(
            message: InterfaceString.Friends.ImportError(message)
        )

        let action = AlertAction(title: InterfaceString.OK, style: .dark) { _ in
            completion(.failure(.cancelled))
        }
        alertController.addAction(action)

        controller.present(alertController, animated: true, completion: nil)
    }

    private static func getAddressBook(_ completion: @escaping Completion) {
        switch AddressBookController.authenticationStatus() {
        case .notDetermined:
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { granted, _ in
                if granted {
                    nextTick { completion(.success(AddressBook(store: CNContactStore()))) }
                }
                else {
                    nextTick { completion(.failure(.unauthorized)) }
                }
            }
        case .authorized:
            nextTick { completion(.success(AddressBook(store: CNContactStore()))) }
        default:
            nextTick { completion(.failure(.unauthorized)) }
        }
    }

    private static func authenticationStatus() -> CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
}

var messageComposer: MessageComposerDelegate?
class MessageComposerDelegate: NSObject, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        guard let viewController = controller.presentingViewController else {
            messageComposer = nil
            return
        }

        viewController.dismiss(animated: true) {
            messageComposer = nil
        }
    }
}
