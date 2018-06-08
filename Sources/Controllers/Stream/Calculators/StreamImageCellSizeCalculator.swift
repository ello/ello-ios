////
///  StreamImageCellSizeCalculator.swift
//

class StreamImageCellSizeCalculator: CellSizeCalculator {
    let streamKind: StreamKind

    static func aspectRatioForImageRegion(_ imageRegion: ImageRegion) -> CGFloat {
        guard let asset = imageRegion.asset else { return 4/3 }
        return asset.aspectRatio
    }

    init(streamKind: StreamKind, item: StreamCellItem, width: CGFloat, columnCount: Int) {
        self.streamKind = streamKind
        super.init(item: item, width: width, columnCount: columnCount)
    }

    override func process() {
        let margin: CGFloat
        if (cellItem.type.data as? Regionable)?.isRepost == true {
            margin = StreamTextCell.Size.repostMargin
        }
        else if cellItem.jsonable is ElloComment {
            margin = StreamTextCell.Size.commentMargin
        }
        else {
            margin = 0
        }

        if let imageRegion = cellItem.type.data as? ImageRegion {
            let oneColumnHeight = StreamImageCell.Size.bottomMargin + oneColumnImageHeight(imageRegion, margin: margin)
            let multiColumnHeight = StreamImageCell.Size.bottomMargin + multiColumnImageHeight(imageRegion, margin: margin)
            assignCellHeight(one: oneColumnHeight, multi: multiColumnHeight)
        }
        else if let embedRegion = cellItem.type.data as? EmbedRegion {
            var ratio: CGFloat
            if embedRegion.isAudioEmbed || embedRegion.service == .uStream {
                ratio = 1
            }
            else {
                ratio = 16 / 9
            }

            let multiWidth = calculateColumnWidth(frameWidth: width, columnSpacing: streamKind.horizontalColumnSpacing, columnCount: columnCount) - margin
            let oneColumnHeight = StreamImageCell.Size.bottomMargin + (width - margin) / ratio
            let multiColumnHeight = StreamImageCell.Size.bottomMargin + multiWidth / ratio
            assignCellHeight(one: oneColumnHeight, multi: multiColumnHeight)
        }
        else {
            finish()
        }
    }

    private func oneColumnImageHeight(_ imageRegion: ImageRegion, margin: CGFloat) -> CGFloat {
        var imageWidth = width - margin
        if let assetWidth = imageRegion.asset?.oneColumnAttachment?.width {
            imageWidth = min(imageWidth, CGFloat(assetWidth))
        }
        return ceil(imageWidth / StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion))
    }

    private func multiColumnImageHeight(_ imageRegion: ImageRegion, margin: CGFloat) -> CGFloat {
        var imageWidth = calculateColumnWidth(frameWidth: width, columnSpacing: StreamKind.unknown.horizontalColumnSpacing, columnCount: columnCount) - margin
        if let assetWidth = imageRegion.asset?.gridLayoutAttachment?.width {
            imageWidth = min(imageWidth, CGFloat(assetWidth))
        }
        return ceil(imageWidth / StreamImageCellSizeCalculator.aspectRatioForImageRegion(imageRegion))
    }

}
