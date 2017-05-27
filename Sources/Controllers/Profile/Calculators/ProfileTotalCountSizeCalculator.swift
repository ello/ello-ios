////
///  ProfileTotalCountSizeCalculator.swift
//

import PromiseKit


struct ProfileTotalCountSizeCalculator {

    func calculate(_ item: StreamCellItem) -> Promise<CGFloat> {
        return Promise { fulfill, reject in
            guard
                let user = item.jsonable as? User,
                let count = user.totalViewsCount,
                count > 0
            else {
                fulfill(0)
                return
            }

            fulfill(ProfileTotalCountView.Size.height)
        }
    }
}
