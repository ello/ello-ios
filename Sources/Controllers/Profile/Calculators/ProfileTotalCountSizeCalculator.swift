////
///  ProfileTotalCountSizeCalculator.swift
//

import PromiseKit


struct ProfileTotalCountSizeCalculator {

    func calculate(_ item: StreamCellItem) -> Promise<CGFloat> {
        let (promise, fulfill, _) = Promise<CGFloat>.pending()
        guard
            let user = item.jsonable as? User,
            let count = user.totalViewsCount,
            count > 0
        else {
            fulfill(0)
            return promise
        }

        fulfill(ProfileTotalCountView.Size.height)
        return promise
    }
}
