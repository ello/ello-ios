////
///  ProfileLocationSizeCalculator.swift
//

import FutureKit


public struct ProfileLocationSizeCalculator {

    let promise = Promise<CGFloat>()

    public func calculate(item: StreamCellItem, maxWidth: CGFloat) -> Future<CGFloat> {
        guard let
            user = item.jsonable as? User,
            location = user.location
        where !location.isEmpty
        else {
            promise.completeWithSuccess(0)
            return promise.future
        }

        promise.completeWithSuccess(ProfileLocationView.Size.height)
        return promise.future
    }
}

private extension ProfileStatsSizeCalculator {}
