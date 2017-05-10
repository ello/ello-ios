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
                func config(title: String) -> EditorialCell.Config {
                    var config = EditorialCell.Config()
                    config.title = title
                    return config
                }

                let expectations: [(String, EditorialCell.Config, EditorialCell.Type)] = [
                    ("short title", config(title: "Editorial title"), EditorialCell.self),
                ]
                for (description, config, cellClass) in expectations {
                    it("should have valid snapshot for \(description)") {
                        let subject = cellClass.init()
                        subject.frame.size = CGSize(width: 375, height: 375)
                        subject.config = config
                        expectValidSnapshot(subject)
                    }
                }
            }
        }
    }
}
