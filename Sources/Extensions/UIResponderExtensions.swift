////
///  UIResponderExtensions.swift
//

extension UIResponder {

    func findResponder<T>() -> T? {
        var responder: UIResponder! = self
        while responder != nil {
            if let responder = responder as? T {
                return responder
            }
            responder = responder.next
        }
        return nil
    }

}
