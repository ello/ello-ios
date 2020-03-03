////
///  AnnouncementCellSizeCalculatorSpec.swift
//

@testable import Ello
import Quick
import Nimble


class AnnouncementCellSizeCalculatorSpec: QuickSpec {
    override func spec() {
        describe("AnnouncementCellSizeCalculator") {
            it("calculates a reasonable height") {
                let announcement: Announcement = stub([:])
                let height = AnnouncementCellSizeCalculator.calculateAnnouncementHeight(
                    announcement,
                    cellWidth: 414
                )
                expect(height) == 165
            }
        }
    }
}
