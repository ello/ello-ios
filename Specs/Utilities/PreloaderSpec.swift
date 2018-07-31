////
///  PreloaderSpec.swift
//

@testable import Ello
import Quick
import Nimble

class PreloaderSpec: QuickSpec {
    override func spec() {
        var subject: Preloader!
        var mdpi: Attachment!
        var hdpi: Attachment!
        var xhdpi: Attachment!
        var regular: Attachment!
        var asset: Asset!
        var imageRegion: ImageRegion!
        var oneImagePost: Post!
        var twoImagePost: Post!
        var threeImagePost: Post!
        var oneImageComment: ElloComment!
        var threeImageComment: ElloComment!
        var user1: User!
        var user2: User!
        var user3: User!
        var avatarAsset1: Asset!
        var avatarAsset2: Asset!
        var avatarAsset3: Asset!

        let fakeManager = FakeImageManager()

        beforeEach {
            subject = Preloader()
            fakeManager.reset()
            subject.manager = fakeManager

            mdpi = Attachment.stub([
                "url": URL(string: "http://www.example.com/mdpi.jpg")!,
                "height": 2, "width": 5, "type": "jpeg", "size": 45644
            ])

            hdpi = Attachment.stub([
                "url": URL(string: "http://www.example.com/hdpi.jpg")!,
                "height": 2, "width": 5, "type": "jpeg", "size": 45644
            ])

            xhdpi = Attachment.stub([
                "url": URL(string: "http://www.example.com/xhdpi.jpg")!,
                "height": 2, "width": 5, "type": "jpeg", "size": 45644
                ])

            regular = Attachment.stub([
                "url": URL(string: "http://www.example.com/regular.jpg")!,
                "height": 2, "width": 5, "type": "jpeg", "size": 45644
            ])

            asset = Asset.stub([
                "xhdpi": xhdpi, "hdpi": hdpi, "mdpi": mdpi
            ])

            imageRegion = ImageRegion.stub([
                "asset": asset,
                "alt": "some-altness",
                "url": URL(string: "http://www.example.com/url.jpg")!
            ])

            avatarAsset1 = Asset.stub([
                "regular": regular
            ])

            avatarAsset2 = Asset.stub([
                "regular": regular
            ])

            avatarAsset3 = Asset.stub([
                "regular": regular
            ])

            user1 = User.stub([
                "avatar": avatarAsset1
            ])

            user2 = User.stub([
                "avatar": avatarAsset2
            ])

            user3 = User.stub([
                "avatar": avatarAsset3
            ])

            oneImagePost = Post.stub([
                "content": [imageRegion],
                "author": user1
            ])

            twoImagePost = Post.stub([
                "content": [imageRegion, imageRegion],
                "author": user2
            ])

            threeImagePost = Post.stub([
                "content": [imageRegion, imageRegion, imageRegion],
                "author": user3
            ])

            oneImageComment = ElloComment.stub([
                "content": [imageRegion],
                "author": user1
            ])

            threeImageComment = ElloComment.stub([
                "content": [imageRegion, imageRegion, imageRegion],
                "author": user3
            ])
        }

        describe("Preloader.preloadImages(_)") {

            it("preloads notification image assets and avatars") {

                let notificationOne: Notification = stub(["subject": oneImagePost])
                let notificationTwo: Notification = stub(["subject": twoImagePost])
                subject.preloadImages([notificationOne, notificationTwo])

                expect(fakeManager.downloads.count) == 5
            }

            it("preloads posts image assets and avatars") {
                subject.preloadImages([oneImagePost, twoImagePost, threeImagePost])

                expect(fakeManager.downloads.count) == 9
            }

            it("preloads comments image assets and avatars") {
                subject.preloadImages([oneImageComment, threeImageComment])

                expect(fakeManager.downloads.count) == 6
            }
        }
    }
}
