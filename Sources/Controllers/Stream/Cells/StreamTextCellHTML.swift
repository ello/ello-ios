////
///  StreamTextCellHTML.swift
//

struct StreamTextCellHTML {

    static var indexFile: String?

    static func indexFileAsString() -> String {
        if let indexFile = StreamTextCellHTML.indexFile {
            return indexFile
        }
        else {
            let indexHTML = Bundle.main.path(
                forResource: "index",
                ofType: "html",
                inDirectory: "www"
            )!

            var error: NSError?
            let indexAsText: NSString?
            do {
                indexAsText = try NSString(
                    contentsOfFile: indexHTML,
                    encoding: String.Encoding.utf8.rawValue
                )
            }
            catch let error1 as NSError {
                error = error1
                indexAsText = nil
            }
            if let indexAsText = indexAsText, error == nil {
                StreamTextCellHTML.indexFile = indexAsText as String
            }
            else {
                StreamTextCellHTML.indexFile = ""
            }
            return StreamTextCellHTML.indexFile!
        }
    }

    static func postHTML(_ string: String) -> String {
        var htmlString = StreamTextCellHTML.indexFileAsString()
        htmlString = htmlString.replacingOccurrences(of: "{{base-url}}", with: ElloURI.baseURL)
        htmlString = htmlString.replacingOccurrences(of: "{{post-content}}", with: string)
        return htmlString
    }

    static func editorialHTML(_ string: String) -> String {
        var htmlString = StreamTextCellHTML.postHTML(string)
        htmlString = htmlString.replacingOccurrences(
            of: "background-color: white;",
            with: "background-color: transparent;"
        )
        htmlString = htmlString.replacingOccurrences(
            of: "</style>",
            with: "body { color: white; }</style>"
        )
        return htmlString
    }

    static func artistInviteHTML(_ string: String) -> String {
        var htmlString = StreamTextCellHTML.postHTML(string)
        htmlString = htmlString.replacingOccurrences(
            of: "background-color: white;",
            with: "background-color: #f2f2f2;"
        )
        return htmlString
    }

    static func artistInviteGuideHTML(_ string: String) -> String {
        var htmlString = StreamTextCellHTML.postHTML(string)
        htmlString = htmlString.replacingOccurrences(
            of: "</style>",
            with: "body { color: #aaa; }</style>"
        )
        return htmlString
    }
}
