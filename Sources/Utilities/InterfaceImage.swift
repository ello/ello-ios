////
///  InterfaceImage.swift
//

import SVGKit


enum InterfaceImage: String {
    enum Style {
        case normal
        case white
        case selected
        case disabled
        case red
        case green  // used by the "watching" lightning bolt
        case orange  // used by the "selected" star

        case dynamic
        case inverted
    }

    case elloLogo = "ello_logo"
    case elloType = "ello_type"
    case elloLogoGrey = "ello_logo_grey"
    case elloGrayLineLogo = "ello_gray_line_logo"

    // Post Action Icons
    case eye = "eye"
    case heart = "hearts"
    case heartOutline = "hearts_outline"
    case giantHeart = "hearts_giant"
    case repost = "repost"
    case share = "share"
    case xBox = "xbox"
    case pencil = "pencil"
    case reply = "reply"
    case flag = "flag"
    case featurePost = "feature_post"

    // Social logos
    case logoMedium = "logo_medium"

    // Badges
    case badgeFeatured = "badge_featured"

    // Location Marker Icon
    case marker = "marker"

    // Notification Icons
    case comments = "bubble"
    case commentsOutline = "bubble_outline"
    case invite = "relationships"
    case watch = "watch"

    // TabBar Icons
    case home = "home"
    case discover = "discover"
    case bolt = "bolt"
    case omni = "omni"
    case person = "person"
    case narrationPointer = "narration_pointer"

    // Validation States
    case validationLoading = "circ"
    case validationError = "x_red"
    case validationOK = "check_green"
    case smallCheck = "small_check_green"

    // NavBar Icons
    case search = "search"
    case searchField = "search_small"
    case burger = "burger"
    case gridView = "grid_view"
    case listView = "list_view"

    // Omnibar
    case reorder = "reorder"
    case photoPicker = "photo_picker"
    case textPicker = "text_picker"
    case camera = "camera"
    case library = "library"
    case check = "check"
    case link = "link"
    case breakLink = "breaklink"

    // Commenting
    case replyAll = "replyall"
    case bubbleBody = "bubble_body"
    case bubbleTail = "bubble_tail"

    // Hire me mail button
    case mail = "mail"

    // Profile
    case roleAdmin = "role_admin"

    // Alert
    case question = "question"

    // BuyButton
    case buyButton = "$"
    case addBuyButton = "$_add"
    case setBuyButton = "$_set"

    // OnePassword
    case onePassword = "1password"

    // Artist Invites
    case circleCheck = "circle_check"
    case circleCheckLarge = "circle_check_large"
    case star = "star"

    // "New Posts" arrow
    case arrowRight = "arrow_right"
    case arrowUp = "arrow_up"

    // Generic
    case x = "x"
    case dots = "dots"
    case dotsLight = "dots_light"
    case plusSmall = "plussmall"
    case checkSmall = "checksmall"
    case forwardChevron = "abracket"
    case backChevron = "chevron"

    // Embeds
    case audioPlay = "embetter_audio_play"
    case videoPlay = "embetter_video_play"

    func image(_ style: Style) -> UIImage? {
        switch style {
        case .normal: return normalImage
        case .white: return whiteImage
        case .selected: return selectedImage
        case .disabled: return disabledImage
        case .red: return redImage
        case .green: return greenImage
        case .orange: return orangeImage

        case .dynamic:
            if #available(iOS 13, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    return whiteImage
                }
                else {
                    return normalImage
                }
            }
            else {
                return normalImage
            }
        case .inverted:
            if #available(iOS 13, *) {
                if UITraitCollection.current.userInterfaceStyle == .dark {
                    return normalImage
                }
                else {
                    return whiteImage
                }
            }
            else {
                return whiteImage
            }
        }
    }

    private static func svgkImage(_ name: String) -> SVGKImage? {
        return SVGKImage(named: "\(name).svg")
    }

    static func toUIImage(_ svgkImage: SVGKImage) -> UIImage {
        return svgkImage.uiImage.withRenderingMode(.alwaysOriginal)
    }

    var normalSVGK: SVGKImage? {
        switch self {
        case .audioPlay,
            .bubbleTail,
            .buyButton,
            .elloLogo,
            .elloLogoGrey,
            .elloGrayLineLogo,
            .giantHeart,
            .logoMedium,
            .marker,
            .narrationPointer,
            .validationError,
            .validationOK,
            .smallCheck,
            .videoPlay:
            return InterfaceImage.svgkImage(self.rawValue)
        default:
            return InterfaceImage.svgkImage("\(self.rawValue)_normal")
        }
    }
    var normalImage: UIImage! {
        return InterfaceImage.toUIImage(normalSVGK!)
    }

    var selectedSVGK: SVGKImage? {
        return InterfaceImage.svgkImage("\(self.rawValue)_selected")
    }
    var selectedImage: UIImage! {
        return InterfaceImage.toUIImage(selectedSVGK!)
    }

    var whiteSVGK: SVGKImage? {
        switch self {
        case .arrowRight,
            .arrowUp,
            .backChevron,
            .breakLink,
            .bolt,
            .bubbleBody,
            .camera,
            .checkSmall,
            .circleCheck,
            .circleCheckLarge,
            .comments,
            .commentsOutline,
            .discover,
            .elloType,
            .eye,
            .forwardChevron,
            .heart,
            .heartOutline,
            .home,
            .invite,
            .library,
            .link,
            .mail,
            .omni,
            .onePassword,
            .pencil,
            .person,
            .photoPicker,
            .plusSmall,
            .reorder,
            .repost,
            .roleAdmin,
            .share,
            .textPicker,
            .xBox,
            .x:
            return InterfaceImage.svgkImage("\(self.rawValue)_white")
        default:
            return nil
        }
    }
    var whiteImage: UIImage? {
        return whiteSVGK.map { InterfaceImage.toUIImage($0) }
    }

    var disabledSVGK: SVGKImage? {
        switch self {
        case .forwardChevron, .addBuyButton, .backChevron, .repost:
            return InterfaceImage.svgkImage("\(self.rawValue)_disabled")
        default:
            return nil
        }
    }
    var disabledImage: UIImage? {
        return disabledSVGK.map { InterfaceImage.toUIImage($0) }
    }

    var redSVGK: SVGKImage? {
        switch self {
        case .x:
            return InterfaceImage.svgkImage("\(self.rawValue)_red")
        default:
            return nil
        }
    }
    var redImage: UIImage? {
        return redSVGK.map { InterfaceImage.toUIImage($0) }
    }

    var greenSVGK: SVGKImage? {
        switch self {
        case .watch, .circleCheck, .circleCheckLarge:
            return InterfaceImage.svgkImage("\(self.rawValue)_green")
        default:
            return nil
        }
    }
    var greenImage: UIImage? {
        return greenSVGK.map { InterfaceImage.toUIImage($0) }
    }

    var orangeSVGK: SVGKImage? {
        switch self {
        case .star:
            return InterfaceImage.svgkImage("\(self.rawValue)_orange")
        default:
            return nil
        }
    }
    var orangeImage: UIImage? {
        return orangeSVGK.map { InterfaceImage.toUIImage($0) }
    }
}
