////
///  Tag.swift
//

let PreserveWs = [
    "style",
    "script"
]

let Singletons = [
    "area",
    "base",
    "br",
    "col",
    "command",
    "embed",
    "hr",
    "img",
    "input",
    "link",
    "meta",
    "param",
    "source"
]

enum State: String {
    case start = "Start"
    case doctype = "Doctype"
    case reset = "Reset"
    case end = "End"
    case tagOpen = "TagOpen"
    case tagClose = "TagClose"
    case tagWs = "TagWs"
    case tagGt = "TagGt"
    case singleton = "Singleton"
    case attrReset = "AttrReset"
    case attr = "Attr"
    case attrEq = "AttrEq"
    case attrDqt = "AttrDqt"
    case attrSqt = "AttrSqt"
    case attrValue = "AttrValue"
    case attrDvalue = "AttrDvalue"
    case attrSvalue = "AttrSvalue"
    case attrCdqt = "AttrCdqt"
    case attrCsqt = "AttrCsqt"
    case text = "Text"
    case cdata = "Cdata"
    case ieOpen = "IeOpen"
    case ieClose = "IeClose"
    case predoctypeWhitespace = "PredoctypeWhitespace"
    case predoctypeCommentOpen = "PredoctypeCommentOpen"
    case predoctypeComment = "PredoctypeComment"
    case predoctypeCommentClose = "PredoctypeCommentClose"
    case commentOpen = "CommentOpen"
    case comment = "Comment"
    case commentClose = "CommentClose"

    var nextPossibleStates: [State] {
        switch self {
        case .start: return [.tagOpen, .doctype, .predoctypeWhitespace, .predoctypeCommentOpen, .text, .end]
        case .doctype: return [.reset]
        case .reset: return [.tagOpen, .ieOpen, .ieClose, .commentOpen, .tagClose, .text, .end]
        case .end: return []
        case .tagOpen: return [.attrReset]
        case .tagClose: return [.reset]
        case .tagWs: return [.attr, .singleton, .tagGt]
        case .tagGt: return [.cdata, .reset]
        case .singleton: return [.reset]
        case .attrReset: return [.tagWs, .singleton, .tagGt]
        case .attr: return [.tagWs, .attrEq, .tagGt, .singleton]
        case .attrEq: return [.attrValue, .attrDqt, .attrSqt]
        case .attrDqt: return [.attrDvalue]
        case .attrSqt: return [.attrSvalue]
        case .attrValue: return [.tagWs, .tagGt, .singleton]
        case .attrDvalue: return [.attrCdqt]
        case .attrSvalue: return [.attrCsqt]
        case .attrCdqt: return [.tagWs, .tagGt, .singleton]
        case .attrCsqt: return [.tagWs, .tagGt, .singleton]
        case .text: return [.reset]
        case .cdata: return [.tagClose]
        case .ieOpen: return [.reset]
        case .ieClose: return [.reset]
        case .predoctypeWhitespace: return [.start]
        case .predoctypeCommentOpen: return [.predoctypeComment]
        case .predoctypeComment: return [.predoctypeCommentClose]
        case .predoctypeCommentClose: return [.start]
        case .commentOpen: return [.comment]
        case .comment: return [.commentClose]
        case .commentClose: return [.reset]
        }
    }

    func match(_ str: String) -> String {
        switch self {
        case .start:                  return ""
        case .reset:                  return ""
        case .doctype:                return (str.lowercased() ~ "^<!doctype .*?>") ?? ""
        case .end:                    return ""
        case .tagOpen:                return (str ~ "^<[a-zA-Z]([-_]?[a-zA-Z0-9])*") ?? ""
        case .tagClose:               return (str ~ "^</[a-zA-Z]([-_]?[a-zA-Z0-9])*>") ?? ""
        case .tagWs:                  return (str ~ "^[ \t\n]+") ?? ""
        case .tagGt:                  return (str ~ "^>") ?? ""
        case .singleton:              return (str ~ "^/>") ?? ""
        case .attrReset:              return ""
        case .attr:                   return (str ~ "^[a-zA-Z]([-_]?[a-zA-Z0-9])*") ?? ""
        case .attrEq:                 return (str ~ "^=") ?? ""
        case .attrDqt:                return (str ~ "^\"") ?? ""
        case .attrSqt:                return (str ~ "^'") ?? ""
        case .attrValue:              return (str ~ "^[a-zA-Z0-9]([-_]?[a-zA-Z0-9])*") ?? ""
        case .attrDvalue:             return (str ~ "^[^\"]*") ?? ""
        case .attrSvalue:             return (str ~ "^[^']*") ?? ""
        case .attrCdqt:               return (str ~ "^\"") ?? ""
        case .attrCsqt:               return (str ~ "^'") ?? ""
        case .cdata:                  return (str ~ "^(//)?<!\\[CDATA\\[([^>]|>)*?//]]>") ?? ""
        case .text:                   return (str ~ "^(.|\n)+?($|(?=<[!/a-zA-Z]))") ?? ""
        case .ieOpen:                 return (str ~ "^<!(?:--)?\\[if.*?\\[>") ?? ""
        case .ieClose:                return (str ~ "^<!\\[endif\\[(?:--)?>") ?? ""
        case .predoctypeWhitespace:   return (str ~ "^[ \t\n]+") ?? ""
        case .predoctypeCommentOpen:  return (str ~ "^<!--") ?? ""
        case .predoctypeComment:      return (str ~ "^(.|\n)*?(?=-->)") ?? ""
        case .predoctypeCommentClose: return (str ~ "^-->") ?? ""
        case .commentOpen:            return (str ~ "^<!--") ?? ""
        case .comment:                return (str ~ "^(.|\n)*?(?=-->)") ?? ""
        case .commentClose:           return (str ~ "^-->") ?? ""
        }
    }

    func detect(_ str: String) -> Bool {
        switch self {
        case .start:                  return true
        case .reset:                  return true
        case .doctype:                return str.lowercased() =~ "^<!doctype .*?>"
        case .end:                    return str.characters.count == 0
        case .tagOpen:                return str =~ "^<[a-zA-Z]([-_]?[a-zA-Z0-9])*"
        case .tagClose:               return str =~ "^</[a-zA-Z]([-_]?[a-zA-Z0-9])*>"
        case .tagWs:                  return str =~ "^[ \t\n]+"
        case .tagGt:                  return str =~ "^>"
        case .singleton:              return str =~ "^/>"
        case .attrReset:              return true
        case .attr:                   return str =~ "^[a-zA-Z]([-_]?[a-zA-Z0-9])*"
        case .attrEq:                 return str =~ "^="
        case .attrDqt:                return str =~ "^\""
        case .attrSqt:                return str =~ "^'"
        case .attrValue:              return str =~ "^[a-zA-Z0-9]([-_]?[a-zA-Z0-9])*"
        case .attrDvalue:             return str =~ "^[^\"]*"
        case .attrSvalue:             return str =~ "^[^']*"
        case .attrCdqt:               return str =~ "^\""
        case .attrCsqt:               return str =~ "^'"
        case .cdata:                  return str =~ "^(//)?<!\\[CDATA\\[([^>]|>)*?//]]>"
        case .text:                   return str =~ "^(.|\n)+?($|(?=<[!/a-zA-Z]))"
        case .ieOpen:                 return str =~ "^<!(?:--)?\\[if.*?\\[>"
        case .ieClose:                return str =~ "^<!\\[endif\\](?:--)?>"
        case .predoctypeWhitespace:   return str =~ "^[ \t\n]+"
        case .predoctypeCommentOpen:  return str =~ "^<!--"
        case .predoctypeComment:      return str =~ "^(.|\n)*?(?=-->)"
        case .predoctypeCommentClose: return str =~ "^-->"
        case .commentOpen:            return str =~ "^<!--"
        case .comment:                return str =~ "^(.|\n)*?(?=-->)"
        case .commentClose:           return str =~ "^-->"
        }
    }
}

enum AttrValue {
    case `true`
    case `false`
    case value(value: String)

    func toString(_ tag: String) -> String {
        switch self {
            case .`false`: return ""
            case .`true`: return tag
            case let .value(value): return "\"\(value)\""
        }
    }
}

class Tag: CustomStringConvertible {
    var isSingleton = false
    var name: String?
    var attrs = [String: AttrValue]()
    var tags = [Tag]()
    var text: String?
    var comment: String?

    init() {}
    init?(input: String) {
        var state: State = .start
        var lastTag = self
        var lastAttr: String? = nil
        var parentTags = [Tag]()
        var preWhitespace: String? = nil

        var tmp = input as NSString
        tmp = tmp.replacingOccurrences(of: "\r\n", with: "\n") as NSString
        tmp = tmp.replacingOccurrences(of: "\r", with: "\n") as NSString
        let html = tmp as String

        var c = html.characters.startIndex
        while state != .end {
            let current = html.substring(with: Range<String.CharacterView.Index>(c ..< html.characters.endIndex))

            var nextPossibleStates = [State]()
            for possible in state.nextPossibleStates {
                if possible.detect(current) {
                    nextPossibleStates.append(possible)
                }
            }
            if nextPossibleStates.count == 0 {
                return nil
            }

            let nextState = nextPossibleStates.first!
            let value = nextState.match(current)
            c = html.characters.index(c, offsetBy: value.characters.count)

            switch nextState {
            case .doctype:
                let doctype = Doctype()
                let regex = Regex("^<!doctype (.*?)>$")!
                let match = regex.matches(value.lowercased())
                doctype.name = match[1]
                lastTag.tags.append(doctype)
                preWhitespace = nil
            case .predoctypeWhitespace:
                preWhitespace = value
            case .tagOpen:
                if let pre = preWhitespace {
                    let tag = Tag()
                    tag.text = pre.entitiesDecoded()
                    lastTag.tags.append(tag)
                    preWhitespace = nil
                }

                let newTag = Tag()
                let name = (value as NSString).substring(with: NSRange(location: 1, length: value.characters.count - 1))
                newTag.name = name
                newTag.isSingleton = Singletons.contains(name)
                lastTag.tags.append(newTag)
                parentTags.append(lastTag)

                lastTag = newTag
                lastAttr = nil
            case .attr:
                lastAttr = value
            case .tagWs:
                if let lastAttr = lastAttr {
                    lastTag.attrs[lastAttr] = .true
                }
                lastAttr = nil
            case .attrValue, .attrDvalue, .attrSvalue:
                if let lastAttr = lastAttr {
                    lastTag.attrs[lastAttr] = .value(value: value)
                }
                lastAttr = nil
            case .tagGt:
                if let lastAttr = lastAttr {
                    lastTag.attrs[lastAttr] = .true
                }

                if lastTag.isSingleton && parentTags.count > 0 {
                    lastTag = parentTags.removeLast()
                }
            case .singleton, .tagClose, .ieClose:
                if parentTags.count > 0 {
                    lastTag = parentTags.removeLast()
                }
            case .text:
                var text = ""
                if let pre = preWhitespace {
                    text += pre.entitiesDecoded()
                    preWhitespace = nil
                }
                text += value.entitiesDecoded()

                let tag = Tag()
                tag.text = text
                lastTag.tags.append(tag)
            case .cdata:
                let tag = Tag()
                tag.text = value.entitiesDecoded()
                lastTag.tags.append(tag)
            case .comment, .predoctypeComment:
                let tag = Tag()
                tag.comment = value
                lastTag.tags.append(tag)
            default:
                break
            }

            state = nextState
        }
    }

    fileprivate func attrd(_ text: String, addlAttrs: [String: AnyObject] = [:]) -> NSAttributedString {
        let defaultAttrs: [String: AnyObject] = [
            NSFontAttributeName: UIFont.editorFont(),
            NSForegroundColorAttributeName: UIColor.black,
        ]
        return NSAttributedString(string: text, attributes: defaultAttrs + addlAttrs)
    }

    func makeEditable(_ inheritedAttrs: [String: AnyObject] = [:]) -> NSAttributedString {
        if comment != nil {
            return NSAttributedString()
        }

        let retval = NSMutableAttributedString(string: "")
        var newAttrs: [String: AnyObject] = inheritedAttrs
        let text: String? = self.text

        if let tag = name {
            switch tag {
            case "br":
                retval.append(attrd("\n"))
            case "u":
                newAttrs[NSUnderlineStyleAttributeName] = NSUnderlineStyle.styleSingle.rawValue as AnyObject?
            case "b", "strong":
                if let existingFont = inheritedAttrs[NSFontAttributeName] as? UIFont, existingFont.fontName == UIFont.editorItalicFont().fontName
                {
                    newAttrs[NSFontAttributeName] = UIFont.editorBoldItalicFont()
                }
                else {
                    newAttrs[NSFontAttributeName] = UIFont.editorBoldFont()
                }
            case "i", "em":
                if let existingFont = inheritedAttrs[NSFontAttributeName] as? UIFont, existingFont.fontName == UIFont.editorBoldFont().fontName
                {
                    newAttrs[NSFontAttributeName] = UIFont.editorBoldItalicFont()
                }
                else {
                    newAttrs[NSFontAttributeName] = UIFont.editorItalicFont()
                }
            default:
                break
            }
        }

        let innerText: NSAttributedString
        if let text = text {
            innerText = attrd(text, addlAttrs: newAttrs)
        }
        else {
            let tempText = NSMutableAttributedString(string: "")
            for child in tags {
                tempText.append(child.makeEditable(newAttrs))
            }
            innerText = tempText
        }

        if let tag = name, let link = attrs["href"], tag == "a"
        {
            switch link {
            case let .value(url):
                retval.append(attrd("["))
                retval.append(innerText)
                retval.append(attrd("](\(url))"))
            default:
                retval.append(innerText)
            }
        }
        else {
            retval.append(innerText)
        }

        return retval
    }

    func images() -> [URL] {
        var urls = [URL]()

        if let url = imageURL() {
            urls.append(url)
        }
        for child in tags {
            urls += child.images()
        }

        return urls
    }

    fileprivate func imageURL() -> URL? {
        if let tag = name, let src: AttrValue = attrs["src"], tag == "img" {
            switch src {
            case let .value(value):
                return URL(string: value)
            default:
                break
            }
        }
        return nil
    }

    var description: String {
        var retval = ""
        if let tag = name {
            retval += "<\(tag)"
            for (key, value) in attrs {
                retval += " "
                retval += key
                retval += "="
                retval += value.toString(tag)
            }

            if isSingleton {
                retval += " />"
            }
            else {
                retval += ">"
            }
        }

        if let comment = comment {
            retval += "<!-- \(comment) -->\n"
        }

        if let text = text {
            retval += text.entitiesEncoded()
        }

        for child in tags {
            retval += child.description
        }

        if let tag = name, !isSingleton {
            retval += "</\(tag)>"
        }

        return retval
    }
}

class Doctype: Tag {
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

extension NSString {
    func trim() -> NSString {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) as NSString
    }
}
