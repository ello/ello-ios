////
///  ElloAttributedString.swift
//

struct ElloAttributedString {
    private struct HtmlTagTuple {
        let tag: String
        let attributes: String?

        init(_ tag: String, attributes: String? = nil) {
            self.tag = tag
            self.attributes = attributes
        }
    }

    static func parse(_ input: String) -> NSAttributedString? {
        guard let tag = Tag(input: input) else { return nil }
        return tag.makeEditable(NSAttributedString.defaultAttrs())
    }

    static func render(_ input: NSAttributedString) -> String {
        var output = ""
        input.enumerateAttributes(in: NSRange(location: 0, length: input.length), options: .longestEffectiveRangeNotRequired) { attrs, nsrange, stopPtr in
            // (tagName, attributes?)
            var tags = [HtmlTagTuple]()
            if let underlineStyle = attrs[.underlineStyle] as? Int, underlineStyle == NSUnderlineStyle.styleSingle.rawValue {
                tags.append(HtmlTagTuple("u"))
            }

            if let font = attrs[.font] as? UIFont {
                if font.fontName == UIFont.editorBoldFont().fontName {
                    tags.append(HtmlTagTuple("strong"))
                }
                else if font.fontName == UIFont.editorBoldItalicFont().fontName {
                    tags.append(HtmlTagTuple("strong"))
                    tags.append(HtmlTagTuple("em"))
                }
                else if font.fontName == UIFont.editorItalicFont().fontName {
                    tags.append(HtmlTagTuple("em"))
                }
            }

            if let link = attrs[.link] as? URL {
                tags.append(HtmlTagTuple("a", attributes: "href=\"\(link.absoluteString.entitiesEncoded())\""))
            }

            for htmlTag in tags {
                output += "<\(htmlTag.tag)"
                if let attrs = htmlTag.attributes {
                    output += " "
                    output += attrs
                }
                output += ">"
            }

            let string = input.string
            if let range = string.rangeFromNSRange(nsrange) {
                output += String(string[range]).entitiesEncoded()
            }

            for htmlTag in tags.reversed() {
                output += "</\(htmlTag.tag)>"
            }
        }
        return output
    }
}
