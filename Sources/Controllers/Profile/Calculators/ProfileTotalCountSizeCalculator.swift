////
///  ProfileTotalCountSizeCalculator.swift
//

import FutureKit


public struct ProfileTotalCountSizeCalculator {
    let promise = Promise<CGFloat>()

    public func calculate(item: StreamCellItem) -> Future<CGFloat> {
        guard let
            user = item.jsonable as? User
        where
            user.totalViewsCount != nil
        else {
            promise.completeWithSuccess(0)
            return promise.future
        }

        promise.completeWithSuccess(ProfileTotalCountView.Size.height)
        return promise.future
    }
}

private extension ProfileTotalCountSizeCalculator {}
