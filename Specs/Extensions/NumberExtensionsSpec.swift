////
///  NumberExtensionSpec.swift
//

@testable import Ello
import Quick
import Nimble

class NumberExtensionsSpec: QuickSpec {
    override func spec() {

        let expectations: [(Int, String)] = [
            (123, "123"),
            (1234, "1.23K"),
            (12345, "12.35K"),
            (1234567, "1.23M"),
            (1234567890, "1.23B"),
        ]

        for (number, expected) in expectations {
            it("returns \(expected) with \(number)") {
                expect(number.numberToHuman()) == expected
            }
        }

        context("rounding") {

            let expectations: [(Int, Int, String)] = [
                (0, 123, "123"),
                (1, 123, "123"),
                (2, 123, "123"),
                (0, 1234, "1K"),
                (1, 1234, "1.2K"),
                (2, 1234, "1.23K"),
                (0, 12345, "12K"),
                (1, 12345, "12.3K"),
                (2, 12345, "12.35K"),
                (0, 1234567, "1M"),
                (1, 1234567, "1.2M"),
                (2, 1234567, "1.23M"),
                (0, 1234567890, "1B"),
                (1, 1234567890, "1.2B"),
                (2, 1234567890, "1.23B"),
            ]

            for (rounding, number, expected) in expectations {
                it("returns \(expected) with \(number)") {
                    expect(number.numberToHuman(rounding: rounding)) == expected
                }
            }

        }

        context("when told to show zero") {
            it("returns 0 for 0") {
                let number = 0
                expect(number.numberToHuman(showZero: true)) == "0"
            }
        }

        context("when not told to show zero") {
            it("returns an empty string for 0") {
                let number = 0
                expect(number.numberToHuman(showZero: false)) == ""
            }
        }
    }
}
