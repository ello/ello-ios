////
///  ElloAttributedString.swift
//

public struct ElloAttributedString {
    private struct HtmlTagTuple {
        let tag: String
        let attributes: String?

        init(_ tag: String, attributes: String? = nil) {
            self.tag = tag
            self.attributes = attributes
        }
    }

    public static func attrs(allAddlAttrs: [String: AnyObject]...) -> [String: AnyObject] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6

        var attrs: [String: AnyObject] = [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont.defaultFont(),
            NSForegroundColorAttributeName: UIColor.blackColor(),
        ]
        for addlAttrs in allAddlAttrs {
            attrs += addlAttrs
        }
        return attrs
    }

    public static func linkAttrs() -> [String: AnyObject] {
        return attrs([
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
        ])
    }

    public static func split(text: NSAttributedString, split: String = "\n") -> [NSAttributedString] {
        var strings = [NSAttributedString]()
        var current = NSMutableAttributedString()
        var hasLetters = false
        var startNewString = false
        let nsCount = (text.string as NSString).length
        for i in 0..<nsCount {
            let letter = NSMutableAttributedString(attributedString: text)
            if i < nsCount - 1 {
                letter.deleteCharactersInRange(NSRange(location: i + 1, length: nsCount - i - 1))
            }
            if i > 0 {
                letter.deleteCharactersInRange(NSRange(location: 0, length: i))
            }

            if letter.string == "\n" {
                current.appendAttributedString(letter)
                startNewString = true
            }
            else {
                if !startNewString {
                    hasLetters = true
                }
                else if hasLetters {
                    strings.append(current)
                    current = NSMutableAttributedString()
                }
                current.appendAttributedString(letter)
                startNewString = false
            }
        }
        if current.string.characters.count > 0 {
            strings.append(current)
        }
        return strings
    }

    public static func style(text: String, _ addlAttrs: [String: AnyObject] = [:]) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: attrs(addlAttrs))
    }

    public static func parse(input: String) -> NSAttributedString? {
        if let tag = Tag(input: input) {
            return tag.makeEditable(attrs())
        }
        return nil
    }

    public static func render(input: NSAttributedString) -> String {
        var output = ""
        input.enumerateAttributesInRange(NSRange(location: 0, length: input.length), options: .LongestEffectiveRangeNotRequired) { (attrs, range, stopPtr) in
            // (tagName, attributes?)
            var tags = [HtmlTagTuple]()
            if let underlineStyle = attrs[NSUnderlineStyleAttributeName] as? Int
            where underlineStyle == NSUnderlineStyle.StyleSingle.rawValue {
                tags.append(HtmlTagTuple("u"))
            }

            if let font = attrs[NSFontAttributeName] as? UIFont {
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

            if let link = attrs[NSLinkAttributeName] as? NSURL,
                linkString = link.absoluteString
            {
                tags.append(HtmlTagTuple("a", attributes: "href=\"\(linkString.entitiesEncoded())\""))
            }

            for htmlTag in tags {
                output += "<\(htmlTag.tag)"
                if let attrs = htmlTag.attributes {
                    output += " "
                    output += attrs
                }
                output += ">"
            }
            output += (input.string as NSString).substringWithRange(range).entitiesEncoded()
            for htmlTag in tags.reverse() {
                output += "</\(htmlTag.tag)>"
            }
        }
        return output
    }
}
