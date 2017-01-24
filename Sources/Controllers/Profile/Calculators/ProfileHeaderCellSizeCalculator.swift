////
///  ProfileHeaderCellSizeCalculator.swift
//

import FutureKit


class ProfileHeaderCellSizeCalculator {
    static let ratio: CGFloat = 320 / 211

    fileprivate var maxWidth: CGFloat = 0.0
    fileprivate typealias CellJob = (cellItems: [StreamCellItem], width: CGFloat, columnCount: Int, completion: ElloEmptyCompletion)
    fileprivate var cellJobs: [CellJob] = []
    fileprivate var cellItems: [StreamCellItem] = []
    fileprivate var completion: ElloEmptyCompletion = {}

    let statsSizeCalculator = ProfileStatsSizeCalculator()
    let avatarSizeCalculator = ProfileAvatarSizeCalculator()
    let bioSizeCalculator = ProfileBioSizeCalculator()
    let locationSizeCalculator = ProfileLocationSizeCalculator()
    let linksSizeCalculator = ProfileLinksSizeCalculator()
    let namesSizeCalculator = ProfileNamesSizeCalculator()
    let totalCountSizeCalculator = ProfileTotalCountSizeCalculator()

// MARK: Public
    init() {}

    func processCells(_ cellItems: [StreamCellItem], withWidth width: CGFloat, columnCount: Int, completion: @escaping ElloEmptyCompletion) {
        let job: CellJob = (cellItems: cellItems, width: width, columnCount: columnCount, completion: completion)
        cellJobs.append(job)
        if cellJobs.count == 1 {
            processJob(job)
        }
    }

    static func calculateHeightFromCellHeights(_ calculatedCellHeights: CalculatedCellHeights) -> CGFloat? {
        guard
            let profileAvatar = calculatedCellHeights.profileAvatar,
            let profileNames = calculatedCellHeights.profileNames,
            let profileTotalCount = calculatedCellHeights.profileTotalCount,
            let profileStats = calculatedCellHeights.profileStats,
            let profileBio = calculatedCellHeights.profileBio,
            let profileLocation = calculatedCellHeights.profileLocation,
            let profileLinks = calculatedCellHeights.profileLinks
        else { return nil }

        return profileAvatar + profileNames + profileTotalCount + profileStats + profileBio + profileLocation + profileLinks
    }

}

private extension ProfileHeaderCellSizeCalculator {

    func processJob(_ job: CellJob) {

        self.completion = {
            if self.cellJobs.count > 0 {
                self.cellJobs.remove(at: 0)
            }
            job.completion()
            if let nextJob = self.cellJobs.safeValue(0) {
                self.processJob(nextJob)
            }
        }
        self.cellItems = job.cellItems
        self.maxWidth = job.width
        loadNext()
    }

    func loadNext() {

        if let item = cellItems.safeValue(0) {
            if item.jsonable is User {
                calculateAggregateHeights(item)
            }
            else {
                assignCellHeight(0)
            }
        }
        else {
            completion()
        }
    }

    func assignCellHeight(_ height: CGFloat) {
        if let cellItem = cellItems.safeValue(0) {
            self.cellItems.remove(at: 0)
            cellItem.calculatedCellHeights.webContent = height
            cellItem.calculatedCellHeights.oneColumn = height
            cellItem.calculatedCellHeights.multiColumn = height
        }
        loadNext()
    }

    func calculateAggregateHeights(_ item: StreamCellItem) {
        let futures: [(CalculatedCellHeights.Prop, Future<CGFloat>)] = [
            (.profileAvatar, avatarSizeCalculator.calculate(item, maxWidth: maxWidth)),
            (.profileNames, namesSizeCalculator.calculate(item, maxWidth: maxWidth)),
            (.profileTotalCount, totalCountSizeCalculator.calculate(item)),
            (.profileStats, statsSizeCalculator.calculate(item)),
            (.profileBio, bioSizeCalculator.calculate(item, maxWidth: maxWidth)),
            (.profileLocation, locationSizeCalculator.calculate(item, maxWidth: maxWidth)),
            (.profileLinks, linksSizeCalculator.calculate(item, maxWidth: maxWidth)),
        ]

        let done = after(futures.count) {
            let totalHeight = ProfileHeaderCellSizeCalculator.calculateHeightFromCellHeights(item.calculatedCellHeights)!
            self.assignCellHeight(totalHeight)
        }

        for (calcType, future) in futures {
            future
                .onSuccess { height in
                    item.calculatedCellHeights.assign(calcType, height: height)
                    done()
                }
                .onFailorCancel { _ in done() }
        }
    }
}
