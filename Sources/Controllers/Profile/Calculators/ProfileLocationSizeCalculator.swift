////
///  ProfileLocationSizeCalculator.swift
//

import FutureKit


struct ProfileLocationSizeCalculator {

    let promise = Promise<CGFloat>()

    func calculate(_ item: StreamCellItem, maxWidth: CGFloat) -> Future<CGFloat> {
        guard
            let user = item.jsonable as? User,
            let location = user.location, !location.isEmpty
        else {
            promise.completeWithSuccess(0)
            return promise.future
        }

        promise.completeWithSuccess(ProfileLocationView.Size.height)
        return promise.future
    }
}

private extension ProfileStatsSizeCalculator {}
