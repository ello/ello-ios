////
///  ProfileLocationSizeCalculator.swift
//

import PromiseKit


struct ProfileLocationSizeCalculator {

    func calculate(_ item: StreamCellItem, maxWidth: CGFloat) -> Promise<CGFloat> {
        let (promise, fulfill, _) = Promise<CGFloat>.pending()
        guard
            let user = item.jsonable as? User,
            let location = user.location, !location.isEmpty
        else {
            fulfill(0)
            return promise
        }

        fulfill(ProfileLocationView.Size.height)
        return promise
    }
}
