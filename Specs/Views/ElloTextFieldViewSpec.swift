////
///  ElloTextFieldViewSpec.swift
//

@testable import Ello
import Quick
import Nimble


class ElloTextFieldViewSpec: QuickSpec {
    override func spec() {
        describe("Styling helpers") {
            it("should style a text field as an email input") {
                let usernameView = ElloTextFieldView(frame: .zero)
                ElloTextFieldView.styleAsUsername(usernameView)

                expect(usernameView.label.text) == "Username"
                expect(usernameView.textField.text) == ""
                expect(usernameView.textField.autocapitalizationType) == UITextAutocapitalizationType.none
                expect(usernameView.textField.autocorrectionType) == UITextAutocorrectionType.no
                expect(usernameView.textField.spellCheckingType) == UITextSpellCheckingType.no
                expect(usernameView.textField.keyboardAppearance) == UIKeyboardAppearance.dark
                expect(usernameView.textField.enablesReturnKeyAutomatically) == true
                expect(usernameView.textField.returnKeyType) == UIReturnKeyType.next
                expect(usernameView.textField.keyboardType) == UIKeyboardType.asciiCapable
            }

            it("should style a text field as an username input") {
                let emailView = ElloTextFieldView(frame: .zero)
                ElloTextFieldView.styleAsEmail(emailView)

                expect(emailView.label.text) == "Email"
                expect(emailView.textField.text) == ""
                expect(emailView.textField.autocapitalizationType) == UITextAutocapitalizationType.none
                expect(emailView.textField.autocorrectionType) == UITextAutocorrectionType.no
                expect(emailView.textField.spellCheckingType) == UITextSpellCheckingType.no
                expect(emailView.textField.keyboardAppearance) == UIKeyboardAppearance.dark
                expect(emailView.textField.enablesReturnKeyAutomatically) == true
                expect(emailView.textField.returnKeyType) == UIReturnKeyType.next
                expect(emailView.textField.keyboardType) == UIKeyboardType.emailAddress
            }

            it("should style a text field as an password input") {
                let passwordView = ElloTextFieldView(frame: .zero)
                ElloTextFieldView.styleAsPassword(passwordView)

                expect(passwordView.label.text) == "Password"
                expect(passwordView.textField.autocapitalizationType) == UITextAutocapitalizationType.none
                expect(passwordView.textField.autocorrectionType) == UITextAutocorrectionType.no
                expect(passwordView.textField.spellCheckingType) == UITextSpellCheckingType.no
                expect(passwordView.textField.keyboardAppearance) == UIKeyboardAppearance.dark
                expect(passwordView.textField.enablesReturnKeyAutomatically) == true
                expect(passwordView.textField.returnKeyType) == UIReturnKeyType.go
                expect(passwordView.textField.keyboardType) == UIKeyboardType.default
                expect(passwordView.textField.isSecureTextEntry) == true
            }

        }
    }
}
