////
///  SimpleMessageCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class SimpleMessageCellSpec: QuickSpec {

    override func spec() {
        describe("SimpleMessageCell") {

            let sizes: [(CGSize, desc: String)] = [
                (CGSize(width: 375, height: 225), "iPhone 7"),
                (CGSize(width: 320, height: 150), "iPhone 5"),
                (CGSize(width: 768, height: 500), "iPad"),
            ]

            for (size, desc) in sizes {
                it("\(desc) should match snapshot") {
                    let subject = SimpleMessageCell()
                    subject.frame.size = size
                    subject.title = "Nothing To See Here"
                    expectValidSnapshot(subject)
                }
            }
        }
    }
}
