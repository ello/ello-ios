////
///  InterfaceImage.swift
//

import UIKit
import SVGKit


enum InterfaceImage: String {
    enum Style {
        case normal
        case white
        case selected
        case disabled
        case red
        case green
    }

    case elloLogo = "ello_logo"
    case elloLogoGrey = "ello_logo_grey"
    case elloGrayLineLogo = "ello_gray_line_logo"

    // Postbar Icons
    case eye = "eye"
    case heart = "hearts"
    case giantHeart = "hearts_giant"
    case repost = "repost"
    case share = "share"
    case xBox = "xbox"
    case pencil = "pencil"
    case reply = "reply"
    case flag = "flag"

    // Badge Check Icon
    case badgeCheck = "badge_check"

    // Location Marker Icon
    case marker = "marker"

    // Notification Icons
    case comments = "bubble"
    case invite = "relationships"
    case watch = "watch"

    // TabBar Icons
    case sparkles = "sparkles"
    case bolt = "bolt"
    case omni = "omni"
    case person = "person"
    case circBig = "circbig"
    case narrationPointer = "narration_pointer"

    // Validation States
    case validationLoading = "circ"
    case validationError = "x_red"
    case validationOK = "check_green"
    case smallCheck = "small_check_green"

    // NavBar Icons
    case search = "search"
    case burger = "burger"
    case gridView = "grid_view"
    case listView = "list_view"

    // Omnibar
    case reorder = "reorder"
    case camera = "camera"
    case check = "check"
    case arrow = "arrow"
    case link = "link"
    case breakLink = "breaklink"

    // Commenting
    case replyAll = "replyall"
    case bubbleBody = "bubble_body"
    case bubbleTail = "bubble_tail"

    // Relationship
    case whiteStar = "white_star"
    case blackStar = "black_star"

    // Hire me mail button
    case mail = "mail"

    // Alert
    case question = "question"

    // BuyButton
    case buyButton = "$"
    case addBuyButton = "$_add"
    case setBuyButton = "$_set"

    // OnePassword
    case onePassword = "1password"

    // Generic
    case x = "x"
    case dots = "dots"
    case dotsLight = "dots_light"
    case plusSmall = "plussmall"
    case checkSmall = "checksmall"
    case angleBracket = "abracket"

    // Embeds
    case audioPlay = "embetter_audio_play"
    case videoPlay = "embetter_video_play"

    func image(_ style: Style) -> UIImage? {
        switch style {
        case .normal:   return normalImage
        case .white:    return whiteImage
        case .selected: return selectedImage
        case .disabled: return disabledImage
        case .red:      return redImage
        case .green:    return greenImage
        }
    }

    fileprivate func svgNamed(_ name: String) -> UIImage {
        return SVGKImage(named: "\(name).svg").uiImage
    }

    var normalImage: UIImage! {
        switch self {
        case .audioPlay,
            .bubbleTail,
            .buyButton,
            .elloLogo,
            .elloLogoGrey,
            .elloGrayLineLogo,
            .giantHeart,
            .marker,
            .narrationPointer,
            .validationError,
            .validationOK,
            .smallCheck,
            .videoPlay:
            return svgNamed(self.rawValue)
        default:
            return svgNamed("\(self.rawValue)_normal")
        }
    }
    var selectedImage: UIImage! {
        return svgNamed("\(self.rawValue)_selected")
    }
    var whiteImage: UIImage? {
        switch self {
        case .angleBracket,
             .arrow,
             .breakLink,
             .bubbleBody,
             .camera,
             .checkSmall,
             .comments,
             .heart,
             .invite,
             .link,
             .mail,
             .onePassword,
             .pencil,
             .plusSmall,
             .repost,
             .x:
            return svgNamed("\(self.rawValue)_white")
        default:
            return nil
        }
    }
    var disabledImage: UIImage? {
        switch self {
        case .repost, .angleBracket, .addBuyButton:
            return svgNamed("\(self.rawValue)_disabled")
        default:
            return nil
        }
    }
    var redImage: UIImage? {
        switch self {
        case .x:
            return svgNamed("\(self.rawValue)_red")
        default:
            return nil
        }
    }
    var greenImage: UIImage? {
        switch self {
        case .watch:
            return svgNamed("\(self.rawValue)_green")
        default:
            return nil
        }
    }
}
