////
///  ProfileHeaderLayoutView.swift
//

import SnapKit


public class ProfileHeaderLayoutView: ProfileBaseView {
    var calculatedCellHeights: CalculatedCellHeights? {
        didSet {
            guard let calculatedCellHeights = calculatedCellHeights else { return }

            if let avatarHeight = calculatedCellHeights.profileAvatar { avatarHeightConstraint.updateOffset(avatarHeight) }
            if let namesHeight = calculatedCellHeights.profileNames { namesHeightConstraint.updateOffset(namesHeight) }
            if let bioHeight = calculatedCellHeights.profileBio { bioHeightConstraint.updateOffset(bioHeight) }
            if let locationHeight = calculatedCellHeights.profileLocation { locationHeightConstraint.updateOffset(locationHeight) }
            if let linksHeight = calculatedCellHeights.profileLinks { linksHeightConstraint.updateOffset(linksHeight) }

            let bioOrLinksHaveContent = calculatedCellHeights.profileBio > 0 || calculatedCellHeights.profileLinks > 0
            statsView.grayLineVisible = bioOrLinksHaveContent

            let linksHasContent = calculatedCellHeights.profileLinks > 0
            bioView.grayLineVisible = linksHasContent

//            let locationHasContent = calculatedCellHeights.profileLocation > 0

            bioView.grayLineVisible = linksHasContent

            setNeedsLayout()
        }
    }

    let avatarView = ProfileAvatarView()
    let namesView = ProfileNamesView()
    let totalCountView = ProfileTotalCountView()
    let statsView = ProfileStatsView()
    let bioView = ProfileBioView()
    let locationView = ProfileLocationView()
    let linksView = ProfileLinksView()

    var avatarHeightConstraint: Constraint!
    var namesHeightConstraint: Constraint!
    var bioHeightConstraint: Constraint!
    var locationHeightConstraint: Constraint!
    var linksHeightConstraint: Constraint!
}
