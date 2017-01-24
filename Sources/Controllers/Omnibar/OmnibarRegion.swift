////
///  OmnibarRegion.swift
//

enum OmnibarRegion {
    case image(UIImage)
    case imageData(UIImage, Data, String)
    case imageURL(URL)
    case attributedText(NSAttributedString)
    case spacer
    case error(URL)

    static func text(_ str: String) -> OmnibarRegion {
        return attributedText(ElloAttributedString.style(str))
    }
}

extension OmnibarRegion {
    var editable: Bool {
        switch self {
        case .imageData, .image: return true
        case let .attributedText(text): return text.string.characters.count > 0
        default: return false
        }
    }

    var text: NSAttributedString? {
        switch self {
        case let .attributedText(text): return text
        default: return nil
        }
    }

    var image: UIImage? {
        switch self {
        case let .image(image): return image
        case let .imageData(image, _, _): return image
        default: return nil
        }
    }

    var isText: Bool {
        switch self {
        case .attributedText: return true
        default: return false
        }
    }

    var isImage: Bool {
        switch self {
        case .imageData, .image, .imageURL: return true
        default: return false
        }
    }

    var empty: Bool {
        switch self {
        case let .attributedText(text): return text.string.characters.count == 0
        case .spacer: return true
        default: return false
        }
    }

    var isSpacer: Bool {
        switch self {
        case .spacer: return true
        default: return false
        }
    }

    var reuseIdentifier: String {
        switch self {
        case .imageData, .image: return OmnibarImageCell.reuseIdentifier
        case .imageURL: return OmnibarImageDownloadCell.reuseIdentifier
        case .attributedText: return OmnibarTextCell.reuseIdentifier
        case .spacer: return OmnibarRegion.OmnibarSpacerCell
        case .error: return OmnibarErrorCell.reuseIdentifier
        }
    }

    static let OmnibarSpacerCell = "OmnibarSpacerCell"
}

extension OmnibarRegion {
    var rawRegion: NSObject? {
        switch self {
        case let .image(image): return image
        case let .imageData(image, _, _): return image
        case let .attributedText(text): return text
        default: return nil
        }
    }
    static func fromRaw(_ obj: NSObject) -> OmnibarRegion? {
        if let text = obj as? NSAttributedString {
            return .attributedText(text)
        }
        else if let image = obj as? UIImage {
            return .image(image)
        }
        return nil
    }
}

extension OmnibarRegion: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        switch self {
        case let .image(image): return "Image(size: \(image.size))"
        case let .imageData(image, _, _): return "ImageData(size: \(image.size))"
        case let .imageURL(url): return "ImageURL(url: \(url))"
        case let .attributedText(text): return "AttributedText(text: \(text.string))"
        case .spacer: return "Spacer()"
        case .error: return "Error()"
        }
    }

    var debugDescription: String {
        return description
    }

}
