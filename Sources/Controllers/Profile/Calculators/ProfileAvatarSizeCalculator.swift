////
///  ProfileAvatarSizeCalculator.swift
//

import PromiseKit


struct ProfileAvatarSizeCalculator {

    static func calculateHeight(maxWidth: CGFloat) -> CGFloat {
        return ceil(maxWidth / ProfileHeaderCellSizeCalculator.ratio) + ProfileAvatarView.Size.whiteBarHeight
    }

    func calculate(_ item: StreamCellItem, maxWidth: CGFloat) -> Promise<CGFloat> {
        let (promise, fulfill, _) = Promise<CGFloat>.pending()
        fulfill(ProfileAvatarSizeCalculator.calculateHeight(maxWidth: maxWidth))
        return promise
    }
}
