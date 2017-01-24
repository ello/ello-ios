////
///  KeyboardSpec.swift
//

@testable import Ello
import Quick
import Nimble

class KeyboardSpec: QuickSpec {
    override func spec() {
        var window: UIWindow!
        let keyboard: Keyboard = Keyboard.shared
        var textView: UITextView!
        var insetScrollView: UIScrollView!

        xdescribe("Responds to keyboard being shown") {
            beforeEach() {
                let view = UIView(frame: UIScreen.main.bounds)
                window = UIWindow(frame: UIScreen.main.bounds)
                window.makeKeyAndVisible()
                window.addSubview(view)

                textView = UITextView(frame: window.bounds)
                view.addSubview(textView)

                insetScrollView = UIScrollView(frame: window.bounds.grow(up: 20))
                view.addSubview(insetScrollView)

                _ = textView.becomeFirstResponder()
                _ = insetScrollView.becomeFirstResponder()
            }

            it("sets the 'visible' property") {
                expect(keyboard.active).to(equal(true))
            }

            it("sets the 'curve' property") {
                expect(keyboard.curve).toNot(equal(UIViewAnimationCurve(rawValue: 0)))
            }

            it("sets the 'options' property") {
                expect(keyboard.options).toNot(equal(UIViewAnimationOptions(rawValue: 0)))
            }

            it("sets the 'duration' property") {
                expect(keyboard.duration).toNot(equal(0))
            }

            it("sets the 'height' property") {
                expect(keyboard.bottomInset).toNot(equal(0))
            }

            it("sets the 'endFrame' property") {
                expect(keyboard.endFrame).toNot(equal(CGRect.zero))
            }

            it("can calculate insets of the scrollview") {
                let height = textView.frame.size.height
                let calculatedKeyboardTop = height - keyboard.bottomInset
                expect(calculatedKeyboardTop) > 0
                expect(calculatedKeyboardTop) < height
                expect(keyboard.keyboardBottomInset(inView: textView)).to(equal(calculatedKeyboardTop))
            }

            it("can calculate insets of the inset scrollview") {
                // 20
                let height = window.frame.size.height
                let bottomSpace = window.frame.height - insetScrollView.frame.maxY
                let calculatedKeyboardTop = keyboard.bottomInset - bottomSpace
                expect(calculatedKeyboardTop) > 0
                expect(calculatedKeyboardTop) < height
                expect(keyboard.keyboardBottomInset(inView: insetScrollView)).to(equal(calculatedKeyboardTop))
            }
        }
    }
}
