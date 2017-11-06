////
///  ProfileHeaderCellSizeCalculator.swift
//

import PromiseKit


class ProfileHeaderCellSizeCalculator {
    typealias CellJob = (cellItems: [StreamCellItem], width: CGFloat, columnCount: Int, completion: Block)

    static let ratio: CGFloat = 320 / 211

    private var retainCalculators: [Any] = []
    private var maxWidth: CGFloat = 0.0

    private var cellJobs: [CellJob] = []
    private var cellItems: [StreamCellItem] = []
    private var completion: Block = {}

// MARK: Public
    init() {}

    func processCells(_ cellItems: [StreamCellItem], withWidth width: CGFloat, columnCount: Int, completion: @escaping Block) {
        guard cellItems.count > 0 else {
            completion()
            return
        }

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
            let profileBadges = calculatedCellHeights.profileBadges,
            let profileStats = calculatedCellHeights.profileStats,
            let profileBio = calculatedCellHeights.profileBio,
            let profileLocation = calculatedCellHeights.profileLocation,
            let profileLinks = calculatedCellHeights.profileLinks
        else { return nil }

        return profileAvatar + profileNames + max(profileTotalCount, profileBadges) + profileStats + profileBio + profileLocation + profileLinks
    }

}

extension ProfileHeaderCellSizeCalculator {

    func processJob(_ job: CellJob) {
        self.completion = {
            self.retainCalculators = []
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
        let avatarSizeCalculator = ProfileAvatarSizeCalculator()
        let namesSizeCalculator = ProfileNamesSizeCalculator()
        let totalCountSizeCalculator = ProfileTotalCountSizeCalculator()
        let badgesSizeCalculator = ProfileBadgesSizeCalculator()
        let statsSizeCalculator = ProfileStatsSizeCalculator()
        let bioSizeCalculator = ProfileBioSizeCalculator()
        let locationSizeCalculator = ProfileLocationSizeCalculator()
        let linksSizeCalculator = ProfileLinksSizeCalculator()
        self.retainCalculators += [
            avatarSizeCalculator,
            namesSizeCalculator,
            totalCountSizeCalculator,
            badgesSizeCalculator,
            statsSizeCalculator,
            bioSizeCalculator,
            locationSizeCalculator,
            linksSizeCalculator,
        ]

        let promises: [(CalculatedCellHeights.Prop, Promise<CGFloat>)] = [
            (.profileAvatar, avatarSizeCalculator.calculate(item, maxWidth: maxWidth)),
            (.profileNames, namesSizeCalculator.calculate(item, maxWidth: maxWidth)),
            (.profileTotalCount, totalCountSizeCalculator.calculate(item)),
            (.profileBadges, badgesSizeCalculator.calculate(item)),
            (.profileStats, statsSizeCalculator.calculate(item)),
            (.profileBio, bioSizeCalculator.calculate(item, maxWidth: maxWidth)),
            (.profileLocation, locationSizeCalculator.calculate(item, maxWidth: maxWidth)),
            (.profileLinks, linksSizeCalculator.calculate(item, maxWidth: maxWidth)),
        ]

        let done = after(promises.count) {
            let totalHeight = ProfileHeaderCellSizeCalculator.calculateHeightFromCellHeights(item.calculatedCellHeights)!
            self.assignCellHeight(totalHeight)
        }

        for (calcType, promise) in promises {
            promise
                .then { height -> Void in
                    item.calculatedCellHeights.assign(calcType, height: height)
                }
                .always { done() }
        }
    }
}
