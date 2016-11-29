////
///  InterfaceImage.swift
//

import UIKit
import SVGKit


public enum InterfaceImage: String {
    public enum Style {
        case Normal
        case White
        case Selected
        case Disabled
        case Red
        case Green
    }

    case ElloLogo = "ello_logo"
    case ElloGrayLineLogo = "ello_gray_line_logo"

    // Postbar Icons
    case Eye = "eye"
    case Heart = "hearts"
    case GiantHeart = "hearts_giant"
    case Repost = "repost"
    case Share = "share"
    case XBox = "xbox"
    case Pencil = "pencil"
    case Reply = "reply"
    case Flag = "flag"

    // Badge Check Icon
    case BadgeCheck = "badge_check"

    // Location Marker Icon
    case Marker = "marker"

    // Notification Icons
    case Comments = "bubble"
    case Invite = "relationships"
    case Watch = "watch"

    // TabBar Icons
    case Sparkles = "sparkles"
    case Bolt = "bolt"
    case Omni = "omni"
    case Person = "person"
    case CircBig = "circbig"
    case NarrationPointer = "narration_pointer"

    // Validation States
    case ValidationLoading = "circ"
    case ValidationError = "x_red"
    case ValidationOK = "check_green"
    case SmallCheck = "small_check_green"

    // NavBar Icons
    case Search = "search"
    case Burger = "burger"
    case GridView = "grid_view"
    case ListView = "list_view"

    // Omnibar
    case Reorder = "reorder"
    case Camera = "camera"
    case Check = "check"
    case Arrow = "arrow"
    case Link = "link"
    case BreakLink = "breaklink"

    // Commenting
    case ReplyAll = "replyall"
    case BubbleBody = "bubble_body"
    case BubbleTail = "bubble_tail"

    // Relationship
    case WhiteStar = "white_star"
    case BlackStar = "black_star"

    // Hire me mail button
    case Mail = "mail"

    // Alert
    case Question = "question"

    // BuyButton
    case BuyButton = "$"
    case AddBuyButton = "$_add"
    case SetBuyButton = "$_set"

    // OnePassword
    case OnePassword = "1password"

    // Generic
    case X = "x"
    case Dots = "dots"
    case DotsLight = "dots_light"
    case PlusSmall = "plussmall"
    case CheckSmall = "checksmall"
    case AngleBracket = "abracket"

    // Embeds
    case AudioPlay = "embetter_audio_play"
    case VideoPlay = "embetter_video_play"

    func image(style: Style) -> UIImage? {
        switch style {
        case .Normal:   return normalImage
        case .White:    return whiteImage
        case .Selected: return selectedImage
        case .Disabled: return disabledImage
        case .Red:      return redImage
        case .Green:    return greenImage
        }
    }

    private func svgNamed(name: String) -> UIImage {
        return SVGKImage(named: "\(name).svg").UIImage
    }

    var normalImage: UIImage! {
        switch self {
        case .AudioPlay,
            .BubbleTail,
            .BuyButton,
            .ElloLogo,
            .ElloGrayLineLogo,
            .GiantHeart,
            .Marker,
            .NarrationPointer,
            .ValidationError,
            .ValidationOK,
            .SmallCheck,
            .VideoPlay:
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
        case .AngleBracket,
             .Arrow,
             .BreakLink,
             .BubbleBody,
             .Camera,
             .CheckSmall,
             .Comments,
             .Heart,
             .Invite,
             .Link,
             .Mail,
             .OnePassword,
             .Pencil,
             .PlusSmall,
             .Repost,
             .X:
            return svgNamed("\(self.rawValue)_white")
        default:
            return nil
        }
    }
    var disabledImage: UIImage? {
        switch self {
        case .Repost, .AngleBracket, .AddBuyButton:
            return svgNamed("\(self.rawValue)_disabled")
        default:
            return nil
        }
    }
    var redImage: UIImage? {
        switch self {
        case .X:
            return svgNamed("\(self.rawValue)_red")
        default:
            return nil
        }
    }
    var greenImage: UIImage? {
        switch self {
        case .Watch:
            return svgNamed("\(self.rawValue)_green")
        default:
            return nil
        }
    }
}
