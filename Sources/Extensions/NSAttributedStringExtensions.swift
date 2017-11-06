////
///  NSAttributedString.swift
//

struct ElloAttributedText {
    static let Link: NSAttributedStringKey = NSAttributedStringKey("ElloLinkAttributedString")
    static let Object: NSAttributedStringKey = NSAttributedStringKey("ElloObjectAttributedString")
}


extension NSAttributedString {
    static func oldAttrs(_ oldAddrs: [NSAttributedStringKey: Any]) -> [String: Any] {
        return oldAddrs.convert { key, value in
            return (key.rawValue, value)
        }
    }

    static func defaultAttrs(_ allAddlAttrs: [NSAttributedStringKey: Any]...) -> [NSAttributedStringKey: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6

        var attrs: [NSAttributedStringKey: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.defaultFont(),
            .foregroundColor: UIColor.black,
        ]
        for addlAttrs in allAddlAttrs {
            attrs += addlAttrs
        }
        return attrs
    }

    convenience init(defaults string: String) {
        self.init(string: string, attributes: NSAttributedString.defaultAttrs())
    }

    convenience init(_ string: String, color: UIColor = .black, underlineStyle: NSUnderlineStyle? = nil, font: UIFont = .defaultFont(), alignment: NSTextAlignment = .left, lineBreakMode: NSLineBreakMode? = nil) {
        let paragraphStyle = NSMutableParagraphStyle()
        if lineBreakMode != .byTruncatingTail {
            paragraphStyle.lineSpacing = 6
        }
        paragraphStyle.alignment = alignment
        if let lineBreakMode = lineBreakMode {
            paragraphStyle.lineBreakMode = lineBreakMode
        }
        let underlineValue = underlineStyle?.rawValue ?? 0
        let attrs: [NSAttributedStringKey: Any] = [
            .foregroundColor: color,
            .font: font,
            .paragraphStyle: paragraphStyle,
            .underlineStyle: underlineValue,
        ]
        self.init(string: string, attributes: attrs)
    }

    convenience init(label string: String, style: StyledLabel.Style, lineBreakMode: NSLineBreakMode? = nil) {
        self.init(string, color: style.textColor, font: style.font, lineBreakMode: lineBreakMode)
    }

    convenience init(button string: String, style: StyledButton.Style, state: UIControlState = .normal, selected: Bool = false, lineBreakMode: NSLineBreakMode? = nil) {
        let stateColor: UIColor?
        if state == .disabled {
            stateColor = style.disabledTitleColor
        }
        else if state == .highlighted && selected {
            stateColor = style.unselectHighlightedTitleColor ?? style.highlightedTitleColor
        }
        else if state == .highlighted {
            stateColor = style.highlightedTitleColor
        }
        else if state == .selected {
            stateColor = style.selectedTitleColor
        }
        else {
            stateColor = style.titleColor
        }

        let color = stateColor ?? style.titleColor ?? .black
        self.init(string, color: color, underlineStyle: style.underline ? .styleSingle : .styleNone, font: style.font, lineBreakMode: lineBreakMode)
    }

    convenience init(primaryHeader: String, secondaryHeader: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let bold: [NSAttributedStringKey: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.defaultFont(16),
            .paragraphStyle: paragraphStyle,
            ]
        let plain: [NSAttributedStringKey: Any] = [
            .foregroundColor: UIColor.greyA,
            .font: UIFont.defaultFont(16),
            .paragraphStyle: paragraphStyle,
            ]
        let header = NSAttributedString(string: primaryHeader, attributes: bold) +
            NSAttributedString(string: " \(secondaryHeader)", attributes: plain)
        self.init(attributedString: header)
    }

    convenience init(featuredIn categories: [Category], font: UIFont = .defaultFont(18), color: UIColor = .white, alignment: NSTextAlignment = .center) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.alignment = alignment

        let attributes = NSAttributedString.defaultAttrs([
            .paragraphStyle: paragraphStyle,
            .font: font,
            .foregroundColor: color,
        ])

        let featuredIn = NSMutableAttributedString(string: InterfaceString.Profile.FeaturedIn, attributes: attributes)
        let count = categories.count
        for (index, category) in categories.enumerated() {
            let prefix: NSAttributedString
            if index == count - 1 && count > 1 {
                prefix = NSAttributedString(string: " & ", attributes: attributes)
            }
            else if index > 0 {
                prefix = NSAttributedString(string: ", ", attributes: attributes)
            }
            else {
                prefix = NSAttributedString(string: " ", attributes: attributes)
            }

            let categoryString = NSAttributedString(string: category.name, attributes: attributes + [
                ElloAttributedText.Link: "category",
                ElloAttributedText.Object: category,
                .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
            ])

            featuredIn.append(prefix)
            featuredIn.append(categoryString)
        }

        self.init(attributedString: featuredIn)
    }

    func appending(_ str: NSAttributedString) -> NSAttributedString {
        let retval: NSMutableAttributedString = NSMutableAttributedString(attributedString: self)
        retval.append(str)
        return NSAttributedString(attributedString: retval)
    }

    func heightForWidth(_ width: CGFloat) -> CGFloat {
        return ceil(boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil).size.height)
    }

    func widthForHeight(_ height: CGFloat) -> CGFloat {
        return ceil(boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil).size.width)
    }

    func joinWithNewlines(_ other: NSAttributedString) -> NSAttributedString {
        let retVal: NSMutableAttributedString = NSMutableAttributedString(attributedString: self)
        if !other.string.isEmpty {
            if !string.isEmpty {
                if !string.hasSuffix("\n") {
                    retVal.append(NSAttributedString("\n\n"))
                }
                else if !string.hasSuffix("\n\n") {
                    retVal.append(NSAttributedString("\n"))
                }
            }

            retVal.append(other)
        }

        return retVal
    }
}

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    let retval = NSMutableAttributedString(attributedString: left)
    retval.append(right)
    return NSAttributedString(attributedString: retval)
}
