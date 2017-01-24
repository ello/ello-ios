////
///  CalculatedCellHeights.swift
//


typealias OnCalculatedCellHeightsMismatch = (CalculatedCellHeights) -> Void

struct CalculatedCellHeights {
    enum Prop {
        case oneColumn
        case multiColumn
        case webContent
        case profileAvatar
        case profileNames
        case profileTotalCount
        case profileStats
        case profileBio
        case profileLocation
        case profileLinks
    }

    mutating func assign(_ prop: Prop, height: CGFloat) {
        switch prop {
        case .profileAvatar:
            profileAvatar = height
        case .profileNames:
            profileNames = height
        case .profileTotalCount:
            profileTotalCount = height
        case .profileStats:
            profileStats = height
        case .profileBio:
            profileBio = height
        case .profileLocation:
            profileLocation = height
        case .profileLinks:
            profileLinks = height
        default: break
        }
    }

    var oneColumn: CGFloat?
    var multiColumn: CGFloat?
    var webContent: CGFloat?
    var profileAvatar: CGFloat?
    var profileNames: CGFloat?
    var profileTotalCount: CGFloat?
    var profileStats: CGFloat?
    var profileBio: CGFloat?
    var profileLocation: CGFloat?
    var profileLinks: CGFloat?
}
