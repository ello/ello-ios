////
///  StreamImageCellSizeCalculator.swift
//

import Foundation

class StreamImageCellSizeCalculator {
    fileprivate typealias CellJob = (cellItems: [StreamCellItem], width: CGFloat, columnCount: Int, completion: ElloEmptyCompletion)
    fileprivate var cellJobs: [CellJob] = []
    fileprivate var cellWidth: CGFloat = 0.0
    fileprivate var maxWidth: CGFloat = 0.0
    fileprivate var columnCount: Int = 1
    fileprivate var cellItems: [StreamCellItem] = []
    fileprivate var completion: ElloEmptyCompletion = {}

// MARK: Static

    static func aspectRatioForImageRegion(_ imageRegion: ImageRegion) -> CGFloat {
        if let asset = imageRegion.asset {
            var attachment: Attachment?
            if let tryAttachment = asset.hdpi {
                attachment = tryAttachment
            }
            else if let tryAttachment = asset.optimized {
                attachment = tryAttachment
            }

            if let attachment = attachment {
                if let width = attachment.width, let height = attachment.height {
                    return CGFloat(width)/CGFloat(height)
                }
            }
        }
        return 4.0/3.0
    }

// MARK: Public

    func processCells(_ cellItems: [StreamCellItem], withWidth width: CGFloat, columnCount: Int, completion: @escaping ElloEmptyCompletion) {
        let job: CellJob = (cellItems: cellItems, width: width, columnCount: columnCount, completion: completion)
        cellJobs.append(job)
        if cellJobs.count == 1 {
            processJob(job)
        }
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
        self.columnCount = job.columnCount
        loadNext()
    }

    fileprivate func loadNext() {
        self.maxWidth = cellWidth
        if !self.cellItems.isEmpty {
            let item = cellItems.remove(at: 0)
            if (item.type.data as? Regionable)?.isRepost == true {
                maxWidth -= StreamTextCellPresenter.repostMargin
            }
            else if item.jsonable is ElloComment {
                maxWidth -= StreamTextCellPresenter.commentMargin
            }

            if let imageRegion = item.type.data as? ImageRegion {
                item.calculatedCellHeights.oneColumn = StreamImageCell.Size.bottomMargin + oneColumnImageHeight(imageRegion)
                item.calculatedCellHeights.multiColumn = StreamImageCell.Size.bottomMargin + multiColumnImageHeight(imageRegion)
            }
            else if let embedRegion = item.type.data as? EmbedRegion {
                var ratio: CGFloat
                if embedRegion.isAudioEmbed || embedRegion.service == .uStream {
                    ratio = 1.0
                }
                else {
                    ratio = 16.0/9.0
                }
                item.calculatedCellHeights.oneColumn = StreamImageCell.Size.bottomMargin + maxWidth / ratio
                item.calculatedCellHeights.multiColumn = StreamImageCell.Size.bottomMargin + calculateColumnWidth(frameWidth: maxWidth, columnCount: columnCount) / ratio
            }
            loadNext()
        }
        else {
            completion()
        }
    }

    fileprivate func oneColumnImageHeight(_ imageRegion: ImageRegion) -> CGFloat {
        var imageWidth = maxWidth
        if let assetWidth = imageRegion.asset?.oneColumnAttachment?.width {
            imageWidth = min(maxWidth, CGFloat(assetWidth))
        }
        return ceil(imageWidth / StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion))
    }

    fileprivate func multiColumnImageHeight(_ imageBlock: ImageRegion) -> CGFloat {
        var imageWidth = calculateColumnWidth(frameWidth: maxWidth, columnCount: columnCount)
        if let assetWidth = imageBlock.asset?.gridLayoutAttachment?.width {
            imageWidth = min(imageWidth, CGFloat(assetWidth))
        }
        return ceil((imageWidth / StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageBlock)))
    }

}
