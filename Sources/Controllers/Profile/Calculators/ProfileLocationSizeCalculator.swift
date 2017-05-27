////
///  ProfileLocationSizeCalculator.swift
//

import PromiseKit


struct ProfileLocationSizeCalculator {

    func calculate(_ item: StreamCellItem, maxWidth: CGFloat) -> Promise<CGFloat> {
        return Promise { fulfill, reject in
            guard
                let user = item.jsonable as? User,
                let location = user.location, !location.isEmpty
            else {
                fulfill(0)
                return
            }

            fulfill(ProfileLocationView.Size.height)
        }
    }
}
