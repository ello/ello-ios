////
///  StreamImageCellPresenterSpec.swift
//

@testable import Ello
import Quick
import Nimble

class StreamImageCellPresenterSpec: QuickSpec {
    override func spec() {
        beforeEach {
            StreamKind.following.setIsGridView(false)
        }

        describe("StreamImageCellPresenter") {

            context("column number differences") {
                var post: Post!
                var imageRegion: ImageRegion!
                var cell: StreamImageCell!
                var item: StreamCellItem!

                beforeEach {
                    post = Post.stub([:])
                    imageRegion = ImageRegion.stub([:])
                    cell = StreamImageCell.loadFromNib()
                    item = StreamCellItem(jsonable: post, type: .image(data: imageRegion))
                }

                context("single column") {

                    it("configures fail constraints correctly") {
                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.isGridView) == false
                    }
                }

                context("multiple columns") {

                    it("configures fail constraints correctly") {
                        StreamKind.following.setIsGridView(true)
                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.isGridView) == true
                    }
                }
            }

            context("no asset") {

                context("image is a gif") {

                    it("configures a stream image cell") {
                        let post: Post = stub([:])

                        let imageRegion: ImageRegion = stub([
                            "url": URL(string: "http://www.example.com/image.gif")!
                        ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .image(data: imageRegion))

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.isGif) == true
                        expect(cell.isLargeImage) == false
                        expect(cell.largeImagePlayButton?.isHidden) == true
                    }
                }

                context("image is not a gif") {

                    it("configures a stream image cell") {
                        let post: Post = stub([:])

                        let imageRegion: ImageRegion = stub([
                            "url": URL(string: "http://www.example.com/image.jpg")!
                        ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .image(data: imageRegion))

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.isGif) == false
                        expect(cell.isLargeImage) == false
                        expect(cell.largeImagePlayButton?.isHidden) == true
                    }

                }
            }

            context("has asset") {

                context("not a gif") {

                    it("configures a stream image cell") {
                        let post: Post = stub([:])

                        let optimized: Attachment = stub([
                            "url": URL(string: "http://www.example.com/optimized.jpg")!,
                            "type": "image/jpg",
                            "size": 9999999
                        ])

                        let hdpi: Attachment = stub([
                            "url": URL(string: "http://www.example.com/hdpi.jpg")!,
                            "type": "image/jpg",
                            "size": 445566
                        ])

                        let asset: Asset = stub([
                            "hdpi": hdpi,
                            "optimized": optimized
                            ])

                        let imageRegion: ImageRegion = stub([
                            "asset": asset,
                            "url": URL(string: "http://www.example.com/image.jpg")!
                            ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .image(data: imageRegion))

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.isGif) == false
                        expect(cell.isLargeImage) == false
                        expect(cell.largeImagePlayButton?.isHidden) == true
                    }
                }

                context("large filesize video") {

                    it("configures a stream image cell") {
                        let post: Post = stub([:])

                        let optimized: Attachment = stub([
                            "url": URL(string: "http://www.example.com/optimized.gif")!,
                            "type": "image/gif",
                            "size": 9999999
                            ])

                        let hdpi: Attachment = stub([
                            "url": URL(string: "http://www.example.com/hdpi.gif")!,
                            "type": "image/gif",
                            "size": 445566
                            ])

                        let video: Attachment = stub([
                            "url": URL(string: "http://www.example.com/video.mp4")!,
                            "type": "video/mp4",
                            "size": 9999999
                            ])

                        let asset: Asset = stub([
                            "hdpi": hdpi,
                            "video": video,
                            "optimized": optimized
                            ])

                        let imageRegion: ImageRegion = stub([
                            "asset": asset,
                            "url": URL(string: "http://www.example.com/image.gif")!
                            ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .image(data: imageRegion))

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.isGif) == true
                        expect(cell.isLargeImage) == true
                        expect(cell.largeImagePlayButton?.isHidden) == false
                    }
                }

                context("small filesize video") {

                    it("configures a stream image cell") {
                        let post: Post = stub([:])

                        let optimized: Attachment = stub([
                            "url": URL(string: "http://www.example.com/optimized.gif")!,
                            "type": "image/gif",
                            "size": 999_999
                            ])

                        let hdpi: Attachment = stub([
                            "url": URL(string: "http://www.example.com/hdpi.gif")!,
                            "type": "image/gif",
                            "size": 445_566
                            ])

                        let video: Attachment = stub([
                            "url": URL(string: "http://www.example.com/video.mp4")!,
                            "type": "video/mp4",
                            "size": 111_111
                            ])

                        let asset: Asset = stub([
                            "hdpi": hdpi,
                            "video": video,
                            "optimized": optimized
                            ])

                        let imageRegion: ImageRegion = stub([
                            "asset": asset,
                            "url": URL(string: "http://www.example.com/image.gif")!
                            ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .image(data: imageRegion))

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.isGif) == true
                        expect(cell.isLargeImage) == false
                        expect(cell.largeImagePlayButton?.isHidden) == true
                    }
                }

                context("large filesize gif") {

                    it("configures a stream image cell") {
                        let post: Post = stub([:])

                        let optimized: Attachment = stub([
                            "url": URL(string: "http://www.example.com/optimized.gif")!,
                            "type": "image/gif",
                            "size": 9999999
                            ])

                        let hdpi: Attachment = stub([
                            "url": URL(string: "http://www.example.com/hdpi.gif")!,
                            "type": "image/gif",
                            "size": 445566
                            ])

                        let asset: Asset = stub([
                            "hdpi": hdpi,
                            "optimized": optimized
                            ])

                        let imageRegion: ImageRegion = stub([
                            "asset": asset,
                            "url": URL(string: "http://www.example.com/image.gif")!
                            ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .image(data: imageRegion))

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.isGif) == true
                        expect(cell.isLargeImage) == true
                        expect(cell.largeImagePlayButton?.isHidden) == false
                    }
                }

                context("small filesize gif") {

                    it("configures a stream image cell") {
                        let post: Post = stub([:])

                        let optimized: Attachment = stub([
                            "url": URL(string: "http://www.example.com/optimized.gif")!,
                            "type": "image/gif",
                            "size": 445566
                            ])

                        let hdpi: Attachment = stub([
                            "url": URL(string: "http://www.example.com/hdpi.gif")!,
                            "type": "image/gif",
                            "size": 445566
                            ])

                        let asset: Asset = stub([
                            "hdpi": hdpi,
                            "optimized": optimized
                            ])

                        let imageRegion: ImageRegion = stub([
                            "asset": asset,
                            "url": URL(string: "http://www.example.com/image.gif")!
                            ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .image(data: imageRegion))

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.isGif) == true
                        expect(cell.isLargeImage) == false
                        expect(cell.largeImagePlayButton?.isHidden) == true
                    }
                }

                context("buyButton link") {

                    it("hides buyButton by default") {
                        let post: Post = stub([:])

                        let imageRegion: ImageRegion = stub([:])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .image(data: imageRegion))

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.buyButton?.isHidden) == true
                        expect(cell.buyButtonGreen?.isHidden) == true
                    }

                    it("shows buyButton if link is present") {
                        let post: Post = stub([:])

                        let imageRegion: ImageRegion = stub([
                            "buyButtonURL": URL(string: "https://amazon.com")!
                            ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .image(data: imageRegion))

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)

                        expect(cell.buyButton?.isHidden) == false
                        expect(cell.buyButtonGreen?.isHidden) == false
                    }

                    it("sets buy button width to 40 in list") {
                        let post: Post = stub([:])

                        let imageRegion: ImageRegion = stub([
                            "buyButtonURL": URL(string: "https://amazon.com")!
                            ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .image(data: imageRegion))

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)
                        cell.layoutIfNeeded()
                        expect(cell.buyButtonGreen?.frame.size.width) == 40
                        expect(cell.buyButtonGreen?.frame.size.height) == 40
                    }

                    it("sets buy button width to 30 in grid") {
                        StreamKind.following.setIsGridView(true)
                        let post: Post = stub([:])

                        let imageRegion: ImageRegion = stub([
                            "buyButtonURL": URL(string: "https://amazon.com")!
                            ])

                        let cell: StreamImageCell = StreamImageCell.loadFromNib()
                        let item: StreamCellItem = StreamCellItem(jsonable: post, type: .image(data: imageRegion))

                        StreamImageCellPresenter.configure(cell, streamCellItem: item, streamKind: .following, indexPath: IndexPath(item: 0, section: 0), currentUser: nil)
                        cell.layoutIfNeeded()
                        expect(cell.buyButtonGreen?.frame.size.width) == 30
                        expect(cell.buyButtonGreen?.frame.size.height) == 30
                    }
                }
            }
        }
    }
}
