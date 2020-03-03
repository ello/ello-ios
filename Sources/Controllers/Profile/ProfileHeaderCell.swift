////
///  ProfileHeaderCell.swift
//

@objc
protocol EditProfileResponder {
    func onEditProfile()
}

@objc
protocol PostsTappedResponder {
    func onPostsTapped()
}

@objc
protocol ProfileHeaderResponder {
    func onCategoryBadgeTapped()
    func onBadgeTapped(_ badge: String)
    func onMoreBadgesTapped()
    func onLovesTapped()
    func onFollowersTapped()
    func onFollowingTapped()
}

class ProfileHeaderCell: CollectionViewCell {
    var onHeightMismatch: OnCalculatedCellHeightsMismatch?

    // this little hack prevents constraints from breaking on initial load
    override var bounds: CGRect {
        didSet {
            contentView.frame = bounds
        }
    }

    func heightMismatchOccurred(_ height: CGFloat) {
        var calculatedCellHeights = CalculatedCellHeights()
        calculatedCellHeights.oneColumn = height
        calculatedCellHeights.multiColumn = height
        onHeightMismatch?(calculatedCellHeights)
    }
}
