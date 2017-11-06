////
///  Validator.swift
//

struct Validator {

    static func hasValidLinks(_ links: String) -> Bool {
        let splitLinks = links.split(",").map { $0.trimmed() }
        return splitLinks.count > 0 && splitLinks.all {
            return Validator.isValidLink($0)
        }
    }

    static func isValidLink(_ link: String) -> Bool {
        guard let url = URL(string: link) else {
            return false
        }

        if url.scheme == nil {
            return isValidLink("http://\(link)")
        }
        else if url.scheme?.lowercased() == "http" || url.scheme?.lowercased() == "https" {
            return isValidHost(url.host)
        }
        else {
            return false
        }
    }

    private static func isValidHost(_ host: String?) -> Bool {
        guard let host = host else { return false }
        return host.contains(".") && !host.hasPrefix(".") && !host.hasSuffix(".")
    }

    static func hasValidSignUpCredentials(email: String, username: String, password: String) -> Bool {
        return isValidEmail(email) && isValidUsername(username) && isValidPassword(password)
    }

    static func invalidSignUpUsernameReason(_ username: String) -> String? {
        if username.isEmpty {
            return InterfaceString.Validator.UsernameRequired
        }
        else if !isValidUsername(username) {
            return InterfaceString.Validator.UsernameInvalid
        }
        return nil
    }

    static func invalidSignUpEmailReason(_ email: String) -> String? {
        if email.isEmpty {
            return InterfaceString.Validator.EmailRequired
        }
        else if !isValidEmail(email) {
            return InterfaceString.Validator.EmailInvalid
        }
        return nil
    }

    static func invalidSignUpPasswordReason(_ password: String) -> String? {
        if password.isEmpty {
            return InterfaceString.Validator.PasswordRequired
        }
        else if !isValidPassword(password) {
            return InterfaceString.Validator.PasswordInvalid
        }
        return nil
    }

    static func hasValidLoginCredentials(username: String, password: String) -> Bool {
        return (isValidEmail(username) || isValidUsername(username)) && isValidPassword(password)
    }

    static func invalidLoginCredentialsReason(username: String, password: String) -> String? {
        if username.isEmpty {
            return InterfaceString.Validator.UsernameRequired
        }
        else if !(isValidUsername(username) || isValidEmail(username)) {
            return InterfaceString.Validator.SignInInvalid
        }
        else if password.isEmpty {
            return InterfaceString.Validator.PasswordRequired
        }
        else if !isValidPassword(password) {
            return InterfaceString.Validator.PasswordInvalid
        }
        return nil
    }

    static func isValidEmail(_ string: String) -> Bool {
        let emailRegEx = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: string)
        return result
    }

    static func isValidUsername(_ string: String) -> Bool {
        let usernameRegEx = "^[_-]|[\\w-]{2,}$"
        let usernameTest = NSPredicate(format: "SELF MATCHES %@", usernameRegEx)
        let result = usernameTest.evaluate(with: string)
        return result
    }

    static func isValidPassword(_ string: String) -> Bool {
        return string.count >= 8
    }

}
