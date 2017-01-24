////
///  EmptyStreamCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class EmptyStreamCellSpec: QuickSpec {

    override func spec() {
        describe("EmptyStreamCell") {

            let sizes: [(CGSize, desc: String)] = [
                (CGSize(width: 375, height: 225), "iPhone 7"),
                (CGSize(width: 320, height: 150), "iPhone 5"),
                (CGSize(width: 768, height: 500), "iPad"),
            ]

            for (size, desc) in sizes {
                it("\(desc) should match snapshot"){
                    let subject = EmptyStreamCell()
                    subject.title = "Nothing To See Here"
                    expectValidSnapshot(subject, device: .custom(size))
                }
            }
        }
    }
}
