////
///  URLExtensions.swift
//

extension URL {
    static func isValidShorthand(_ url: String) -> Bool {
        return URL.shorthand(url) != nil
    }

    static func shorthand(_ shorthand: String) -> URL? {
        let url: URL
        if let urlTest = URL(string: shorthand), urlTest.scheme?.isEmpty == false {
            url = urlTest
        }
        else if let urlTest = URL(string: "http://\(shorthand)") {
            url = urlTest
        }
        else {
            return nil
        }

        if let host = url.host, host =~ "\\w+\\.\\w+" {
            return url
        }
        return nil
    }

    var hasGifExtension: Bool {
        return pathExtension.lowercased() == "gif"
    }

    var absoluteStringWithoutProtocol: String {
        return (host ?? "") + path
    }
}
