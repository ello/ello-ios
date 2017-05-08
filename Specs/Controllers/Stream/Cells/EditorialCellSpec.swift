////
///  EditorialCellSpec.swift
//

@testable import Ello
import Quick
import Nimble


class EditorialCellSpec: QuickSpec {
    override func spec() {
        describe("EditorialCell") {
            context("snapshots") {
                func config(
                    ) -> EditorialCell.Config {
                    var config = EditorialCell.Config()
                    return config
                }

                let expectations: [(String, EditorialCell.Config)] = [
                    ("short title, short description", config()),
                ]
                for (description, config) in expectations {
                    it("should have valid snapshot for \(description)") {
                        let subject = EditorialCell()
                        subject.frame.size = CGSize(width: 375, height: 375)
                        subject.config = config
                        expectValidSnapshot(subject)
                    }
                }
            }
        }
    }
}
