////
///  StreamTextCellHTMLSpec.swift
//

@testable import Ello
import Quick
import Nimble
import Moya


class StreamTextCellHTMLSpec: QuickSpec {

    override func spec() {

        describe("+indexFileAsString:") {

            it("returns the stub index html file") {
                let indexFile = StreamTextCellHTML.indexFileAsString()

                expect(indexFile).to(contain("id=\"post-container\""))
            }

        }

        describe("+postHTML:") {

            it("returns the stub index html file with custom markup added") {
                let postHTML = StreamTextCellHTML.postHTML("<p>Hi mom, I am some HTML!</p>")
                let expectedHTML = "<p>Hi mom, I am some HTML!</p>"

                expect(postHTML).to(contain(expectedHTML))
            }
        }
    }
}
