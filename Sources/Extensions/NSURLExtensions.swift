////
///  NSURLExtensions.swift
//

public extension NSURL {
    class func isValidShorthand(url: String) -> Bool {
        return NSURL.shorthand(url) != nil
    }

    class func shorthand(shorthand: String) -> NSURL? {
        let url: NSURL
        if let urlTest = NSURL(string: shorthand) where urlTest.scheme?.isEmpty == false {
            url = urlTest
        }
        else if let urlTest = NSURL(string: "http://\(shorthand)") {
            url = urlTest
        }
        else {
            return nil
        }

        if let host = url.host where host =~ "\\w+\\.\\w+" {
            return url
        }
        return nil
    }

    var hasGifExtension: Bool {
        return pathExtension?.lowercaseString == "gif"
    }

    var absoluteStringWithoutProtocol: String {
        return (host ?? "") + (path ?? "")
    }
}
