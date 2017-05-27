////
///  ProfileAvatarSizeCalculator.swift
//

import PromiseKit


struct ProfileAvatarSizeCalculator {

    static func calculateHeight(maxWidth: CGFloat) -> CGFloat {
        return ceil(maxWidth / ProfileHeaderCellSizeCalculator.ratio) + ProfileAvatarView.Size.whiteBarHeight
    }

    func calculate(_ item: StreamCellItem, maxWidth: CGFloat) -> Promise<CGFloat> {
        return Promise { fulfill, _ in
            fulfill(ProfileAvatarSizeCalculator.calculateHeight(maxWidth: maxWidth))
        }
    }
}
