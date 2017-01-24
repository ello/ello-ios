////
///  DateFormattingSpec.swift
//

@testable import Ello
import Quick
import Nimble

// GROSS, thanks Apple for making it hard to change Locale for testing purposes
extension NSLocale {
    class func defaultToArab() {
        method_exchangeImplementations(class_getClassMethod(self, #selector(getter: NSLocale.current)), class_getClassMethod(self, #selector(NSLocale.ello_currentLocale)))
    }

    class func defaultToNormal() {
        method_exchangeImplementations(class_getClassMethod(self, #selector(NSLocale.ello_currentLocale)), class_getClassMethod(self, #selector(getter: NSLocale.current)))
    }

    // MARK: - Method Swizzling

    class func ello_currentLocale() -> NSLocale {
        return NSLocale(localeIdentifier: "uz_Arab")
    }
}


class DateFormattingSpec: QuickSpec {
    override func spec() {

        describe("NSString.toDate()") {

            context("HTTP Date") {

                it("returns an Date from an http data string") {
                    let sep_30_1978 = Date(timeIntervalSince1970: 275961600)
                    expect("Sat, 30 Sep 1978 00:00:00 GMT".toDate(HTTPDateFormatter)) == sep_30_1978
                }
            }

            context("database date") {

                it("returns an Date from a server formatted string") {
                    let sep_30_1978 = Date(timeIntervalSince1970: 275961600)
                    expect("1978-09-30T00:00:00.000Z".toDate()) == sep_30_1978
                }
            }
        }

        describe("ServerDateFormatter") {

            context("arabic locale") {
                it("outputs the correct string") {
                    NSLocale.defaultToArab()
                    let sep_30_1978 = Date(timeIntervalSince1970: 275961600)

                    expect(sep_30_1978.toServerDateString()) == "1978-09-30T00:00:00.000Z"

                    NSLocale.defaultToNormal()
                }
            }

            context("non arabic locale") {
                it("outputs the correct string") {
                    let sep_30_1978 = Date(timeIntervalSince1970: 275961600)

                    expect(sep_30_1978.toServerDateString()) == "1978-09-30T00:00:00.000Z"
                }
            }

        }

        describe("HTTPDateFormatter") {

            context("arabic locale") {
                it("outputs the correct string") {
                    NSLocale.defaultToArab()
                    let sep_30_1978 = Date(timeIntervalSince1970: 275961600)

                    expect(sep_30_1978.toHTTPDateString()) == "Sat, 30 Sep 1978 00:00:00 GMT"

                    NSLocale.defaultToNormal()
                }
            }

            context("non arabic locale") {
                it("outputs the correct string") {
                    let sep_30_1978 = Date(timeIntervalSince1970: 275961600)

                    expect(sep_30_1978.toHTTPDateString()) == "Sat, 30 Sep 1978 00:00:00 GMT"
                }
            }
        }
    }
}
