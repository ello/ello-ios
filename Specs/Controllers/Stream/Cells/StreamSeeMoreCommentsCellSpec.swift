////
///  StreamSeeMoreCommentsCellSpec.swift
//

@testable import Ello
import Quick
import Nimble

class StreamSeeMoreCommentsCellSpec: QuickSpec {

    override func spec() {

        let subject: StreamSeeMoreCommentsCell = StreamSeeMoreCommentsCell.loadFromNib()

        describe("initialization") {

            it("sets IBOutlets") {
                expect(subject.buttonContainer).notTo(beNil())
                expect(subject.seeMoreButton).notTo(beNil())
            }

            it("can be instantiated from storyboard") {
                expect(subject).notTo(beNil())
            }

            it("is a StreamSeeMoreCommentsCell") {
                expect(subject).to(beAKindOf(StreamSeeMoreCommentsCell.self))
            }

        }

    }

}
