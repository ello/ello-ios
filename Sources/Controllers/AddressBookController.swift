////
///  AddressBookController.swift
//

import Contacts
import Result


typealias Completion = (Result<AddressBook, AddressBookError>) -> Void

struct AddressBookController {
    static func promptForAddressBookAccess(fromController controller: UIViewController, completion: @escaping Completion, cancelCompletion: @escaping ElloEmptyCompletion = {}) {
        switch AddressBookController.authenticationStatus() {
        case .authorized:
            proceedWithImport(completion)
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

    fileprivate static func promptForAccess(_ controller: UIViewController, completion: @escaping Completion, cancelCompletion: @escaping ElloEmptyCompletion = {}) {
        let alertController = AlertViewController(message: InterfaceString.Friends.ImportPermissionPrompt, type: .rounded)

        let importMessage = InterfaceString.Friends.ImportAllow
        let action = AlertAction(title: importMessage, style: .green) { action in
            Tracker.shared.importContactsInitiated()
            self.proceedWithImport(completion)
        }
        alertController.addAction(action)

        let cancelMessage = InterfaceString.Friends.ImportNotNow
        let cancelAction = AlertAction(title: cancelMessage, style: .roundedGrayFill) { _ in
            Tracker.shared.importContactsDenied()
            cancelCompletion()
        }
        alertController.addAction(cancelAction)

        controller.present(alertController, animated: true, completion: .none)
    }

    fileprivate static func proceedWithImport(_ completion: @escaping Completion) {
        Tracker.shared.addressBookAccessed()
        AddressBookController.getAddressBook { result in
            nextTick {
                completion(result)
            }
        }
    }

    fileprivate static func displayAddressBookAlert(_ controller: UIViewController, message: String, completion: @escaping Completion) {
        let alertController = AlertViewController(
            message: NSString.localizedStringWithFormat(InterfaceString.Friends.ImportErrorTemplate as NSString, message) as String
        )

        let action = AlertAction(title: InterfaceString.OK, style: .dark) { _ in
            completion(.failure(.cancelled))
        }
        alertController.addAction(action)

        controller.present(alertController, animated: true, completion: .none)
    }

    fileprivate static func getAddressBook(_ completion: @escaping Completion) {
        switch AddressBookController.authenticationStatus() {
        case .notDetermined:
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { granted, _ in
                if granted {
                    completion(.success(AddressBook(store: CNContactStore())))
                }
                else {
                    completion(.failure(.unauthorized))
                }
            }
        case .authorized: completion(.success(AddressBook(store: CNContactStore())))
        default: completion(.failure(.unauthorized))
        }
    }

    fileprivate static func authenticationStatus() -> CNAuthorizationStatus {
        return CNContactStore.authorizationStatus(for: .contacts)
    }
}
