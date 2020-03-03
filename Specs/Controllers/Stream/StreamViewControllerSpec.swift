////
///  StreamViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble
import SSPullToRefresh


class StreamViewControllerSpec: QuickSpec {

    override func spec() {
        var controller: StreamViewController!
        beforeEach {
            controller = StreamViewController()
            showController(controller)
        }

        describe("StreamViewController") {

            describe("hasCellItems(for:)") {
                it("returns 'false' if 0 items") {
                    expect(controller.hasCellItems(for: .streamItems)) == false
                }
                it("returns 'false' if 1 placeholder item") {
                    controller.appendStreamCellItems([
                        StreamCellItem(type: .placeholder, placeholderType: .streamItems)
                    ])
                    expect(controller.hasCellItems(for: .streamItems)) == false
                }
                it("returns 'true' if 1 jsonable item") {
                    controller.appendStreamCellItems([
                        StreamCellItem(type: .streamLoading, placeholderType: .streamItems)
                    ])
                    expect(controller.hasCellItems(for: .streamItems)) == true
                }
                it("returns 'true' if more than 1 jsonable item") {
                    controller.appendStreamCellItems([
                        StreamCellItem(type: .streamLoading, placeholderType: .streamItems),
                        StreamCellItem(type: .streamLoading, placeholderType: .streamItems),
                    ])
                    expect(controller.hasCellItems(for: .streamItems)) == true
                }
            }

            context("responder chain") {
                it("reassigns next responder to PostbarController") {
                    expect(controller.next) === controller.postbarController
                }
            }
        }
    }
}
