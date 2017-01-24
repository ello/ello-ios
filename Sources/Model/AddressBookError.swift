////
///  AddressBookError.swift
//

enum AddressBookError: String, Error {
    case unauthorized = "Please make sure that you have granted Ello access to your contacts in the Privacy Settings"
    case unknown = "Something went wrong! Please try again."
    case cancelled = "Cancelled"
}
