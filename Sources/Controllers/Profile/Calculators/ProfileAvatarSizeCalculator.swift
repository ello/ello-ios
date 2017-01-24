////
///  ProfileAvatarSizeCalculator.swift
//

import FutureKit


struct ProfileAvatarSizeCalculator {

    static func calculateHeight(maxWidth: CGFloat) -> CGFloat {
        return ceil(maxWidth / ProfileHeaderCellSizeCalculator.ratio) + ProfileAvatarView.Size.whiteBarHeight
    }

    func calculate(_ item: StreamCellItem, maxWidth: CGFloat) -> Future<CGFloat> {
        let promise = Promise<CGFloat>()
        promise.completeWithSuccess(ProfileAvatarSizeCalculator.calculateHeight(maxWidth: maxWidth))
        return promise.future
    }
}

private extension ProfileAvatarSizeCalculator {}
