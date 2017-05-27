////
///  CategoryHeaderCellSizeCalculator.swift
//


class CategoryHeaderCellSizeCalculator {
    static let ratio: CGFloat = 320 / 192

    fileprivate typealias CellJob = (cellItems: [StreamCellItem], width: CGFloat, completion: ElloEmptyCompletion)
    fileprivate var cellJobs: [CellJob] = []
    fileprivate var cellWidth: CGFloat = 0.0
    fileprivate var cellItems: [StreamCellItem] = []
    fileprivate var completion: ElloEmptyCompletion = {}

    // MARK: Public

    func processCells(_ cellItems: [StreamCellItem], withWidth width: CGFloat, completion: @escaping ElloEmptyCompletion) {
        guard cellItems.count > 0 else {
            completion()
            return
        }

        let job: CellJob = (cellItems: cellItems, width: width, completion: completion)
        cellJobs.append(job)
        if cellJobs.count == 1 {
            processJob(job)
        }
    }

    static func calculateCategoryHeight(_ category: Category, cellWidth: CGFloat) -> CGFloat {
        let config = CategoryHeaderCell.Config(category: category)
        return CategoryHeaderCellSizeCalculator.calculateHeight(config, cellWidth: cellWidth)
    }

    static func calculatePagePromotionalHeight(_ pagePromotional: PagePromotional, cellWidth: CGFloat) -> CGFloat {
        let config = CategoryHeaderCell.Config(pagePromotional: pagePromotional)
        return CategoryHeaderCellSizeCalculator.calculateHeight(config, cellWidth: cellWidth)
    }

    static func calculateHeight(_ config: CategoryHeaderCell.Config, cellWidth: CGFloat) -> CGFloat {
        var calcHeight: CGFloat = 0
        let textWidth = cellWidth - 2 * CategoryHeaderCell.Size.defaultMargin
        let boundingSize = CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude)

        let attributedTitle = config.attributedTitle
        calcHeight += CategoryHeaderCell.Size.topMargin
        calcHeight += attributedTitle.heightForWidth(textWidth)

        if let attributedBody = config.attributedBody {
            calcHeight += CategoryHeaderCell.Size.bodyMargin
            calcHeight += attributedBody.heightForWidth(textWidth)
        }

        var ctaSize: CGSize = .zero
        var postedBySize: CGSize = .zero
        if let attributedCallToAction = config.attributedCallToAction {
            ctaSize = attributedCallToAction.boundingRect(with: boundingSize, options: [], context: nil).size.integral
        }

        if let attributedPostedBy = config.attributedPostedBy {
            postedBySize = attributedPostedBy.boundingRect(with: boundingSize, options: [], context: nil).size.integral
        }

        calcHeight += CategoryHeaderCell.Size.bodyMargin
        if ctaSize.width + postedBySize.width > textWidth {
            calcHeight += ctaSize.height + CategoryHeaderCell.Size.stackedMargin + postedBySize.height
        }
        else {
            calcHeight += max(ctaSize.height, postedBySize.height)
        }

        calcHeight += CategoryHeaderCell.Size.defaultMargin
        return calcHeight
    }

    // MARK: Private

    fileprivate func processJob(_ job: CellJob) {
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
        self.cellWidth = job.width
        loadNext()
    }

    fileprivate func loadNext() {
        guard !self.cellItems.isEmpty else {
            completion()
            return
        }

        let item = cellItems.remove(at: 0)
        let minHeight = ceil(cellWidth / CategoryHeaderCellSizeCalculator.ratio)
        var calcHeight: CGFloat = 0
        if let category = item.jsonable as? Category {
            calcHeight += CategoryHeaderCellSizeCalculator.calculateCategoryHeight(category, cellWidth: cellWidth)
        }
        else if let pagePromotional = item.jsonable as? PagePromotional {
            calcHeight += CategoryHeaderCellSizeCalculator.calculatePagePromotionalHeight(pagePromotional, cellWidth: cellWidth)
        }

        let height = max(minHeight, calcHeight)
        item.calculatedCellHeights.oneColumn = height
        item.calculatedCellHeights.multiColumn = height
        loadNext()
    }
}
