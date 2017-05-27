////
///  StreamViewControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble
import SSPullToRefresh


class StreamViewControllerSpec: QuickSpec {
    class MockHasAppViewController: UINavigationController, HasAppController {
        let appViewController: AppViewController? = AppViewController()
    }

    override func spec() {

        var controller: StreamViewController!
        beforeEach {
            controller = StreamViewController()
            showController(controller)
        }

        describe("initialization") {

            describe("storyboard") {
                it("IBOutlets are  not nil") {
                    expect(controller.collectionView).notTo(beNil())
                }
            }

            it("can be instantiated from storyboard") {
                expect(controller).notTo(beNil())
            }

            it("is a BaseElloViewController") {
                expect(controller).to(beAKindOf(BaseElloViewController.self))
            }

            it("is a StreamViewController") {
                expect(controller).to(beAKindOf(StreamViewController.self))
            }

        }

        describe("hasCellItems(for:)") {
            it("returns 'false' if 0 items") {
                expect(controller.hasCellItems(for: .profilePosts)) == false
            }
            it("returns 'false' if 1 placeholder item") {
                controller.appendStreamCellItems([StreamCellItem(type: .placeholder, placeholderType: .profilePosts)])
                expect(controller.hasCellItems(for: .profilePosts)) == false
            }
            it("returns 'true' if 1 jsonable item") {
                controller.appendStreamCellItems([StreamCellItem(type: .streamLoading, placeholderType: .profilePosts)])
                expect(controller.hasCellItems(for: .profilePosts)) == true
            }
            it("returns 'true' if more than 1 jsonable item") {
                controller.appendStreamCellItems([
                    StreamCellItem(type: .streamLoading, placeholderType: .profilePosts),
                    StreamCellItem(type: .streamLoading, placeholderType: .profilePosts),
                ])
                expect(controller.hasCellItems(for: .profilePosts)) == true
            }
        }

        xdescribe("viewDidAppear(_:)") {

            context("should reload") {

                context("post detail stream kind") {

                    context("deleted post is current user's post") {
                        it("pops the view controller from the nav stack"){}
                    }

                    context("deteted post is NOT current user's post") {
                        it("does not pop the view controller from the nav stack"){}
                    }
                }

                context("not post detail stream kind") {
                    it("reloads the content"){}
                }
            }

            context("should not reload") {
                it("does not reload"){}
            }
        }

        xdescribe("viewDidDisappear(_:)") {
            it("prevents reloading content if stale"){}
        }

        describe("viewDidLoad()") {
            it("properly configures dataSource") {
                expect(controller.dataSource).to(beAnInstanceOf(StreamDataSource.self))

                // FAILS for some reason
                // let dataSource = controller.collectionView.dataSource! as StreamDataSource
                // expect(dataSource) == controller.dataSource
            }

            it("sets up a postbar controller and assigns it to the datasource") {
                expect(controller.postbarController).notTo(beNil())
            }

            it("configures collectionView") {
                let delegate = controller.collectionView.delegate! as! StreamViewController
                expect(delegate) == controller
                expect(controller.collectionView.alwaysBounceHorizontal) == false
                expect(controller.collectionView.alwaysBounceVertical) == true
            }

            it("adds notification observers") {

            }
        }

        xdescribe("loading more posts on scrolling") {

            beforeEach {
                controller.streamKind = StreamKind.following
                controller.streamService.loadStream(endpoint: controller.streamKind.endpoint)
                    .thenFinally { response in
                        if case let .jsonables(jsonables, responseConfig) = response {
                            controller.appendUnsizedCellItems(StreamCellItemParser().parse(jsonables, streamKind: controller.streamKind))
                            controller.responseConfig = responseConfig
                            controller.doneLoading()
                        }
                    }
                    .catch { _ in
                        controller.doneLoading()
                    }
            }

            it("loads the next page of results when scrolled within 300 of the bottom") {
                expect(controller.collectionView.numberOfItems(inSection: 0)).toEventually(equal(3))
                // controller.collectionView.contentOffset = CGPoint(x: 0, y: 0)
                // expect(controller.collectionView.numberOfItemsInSection(0)) == 6
            }

            it("does not load the next page of results when not scrolled within 300 of the bottom") {
                expect(controller.collectionView.numberOfItems(inSection: 0)).toEventually(equal(3))
            }
        }

        context("protocol conformance") {

            context("WebLinkResponder") {

                it("is a WebLinkResponder") {
                    expect(controller as WebLinkResponder).notTo(beNil())
                }

                describe("webLinkTapped(_:data:)") {
                    var hasAppVC: MockHasAppViewController!

                    beforeEach {
                        // wire up the StreamViewController's hierarchy
                        // the parent controller needs to be a `HasAppController`
                        // but it doesn't need to be wired into an `AppViewController`,
                        // it just needs to return it via the protocol
                        hasAppVC = MockHasAppViewController(rootViewController: controller)
                        showController(hasAppVC.appViewController!)
                    }

                    it("opens external browser if type .external") {
                        controller.webLinkTapped(path: "http://www.example.com", type: ElloURIWrapper(uri: .external), data: "http://www.example.com")
                        let presented = hasAppVC.appViewController!.presentedViewController
                        expect(presented).notTo(beNil())
                        if let browser = (presented as! UINavigationController).viewControllers.first {
                            expect(browser).to(beAKindOf(ElloWebBrowserViewController.self))
                        }
                        else {
                            fail("did not present ElloWebBrowserViewController")
                        }
                    }

                    xit("presents a profile if type .profile") {
                        // not yet implemented
                    }

                    xit("shows a post detail if type .post") {
                        // not yet implemented
                    }

                }
            }

            context("SSPullToRefreshViewDelegate") {

                it("is a SSPullToRefreshViewDelegate") {
                    expect(controller as SSPullToRefreshViewDelegate).notTo(beNil())
                }

                describe("pullToRefreshViewShouldStartLoading(_:)") {

                    it("returns true") {
                        let shouldStartLoading = controller.pull(toRefreshViewShouldStartLoading: controller.pullToRefreshView)
                        expect(shouldStartLoading).to(beTrue())
                    }
                }

                describe("pullToRefreshViewDidStartLoading(_:)") {

                    //TODO: verify data
                    xit("reloads the collectionview") {
                    }
                }
            }

            context("UICollectionViewDelegate") {

                it("is a UICollectionViewDelegate") {
                    expect(controller as UICollectionViewDelegate).notTo(beNil())
                }

                describe("collectionView(_:didSelectItemAtIndexPath:)") {

                    context("a post is found for the given indexPath") {

                        xit("calls postTapped: on the postTappedDelegate") {
                            // need to wire up a collectionview and datasource
                        }
                    }

                    context("a create comment cell is found for the given indexPath") {

                        xit("calls createComment:fromController: on the createPostDelegate") {
                            // need to wire up a collectionview and datasource
                        }
                    }

                    context("no post is found for the given indexPath") {

                        xit("does not call postTapped: on the postTappedDelegate") {

                        }
                    }

                }

                describe("_:shouldSelectItemAtIndexPath:)") {

                    xit("returns true if the streamcell item type is .Header") {
                        // need to wire up a collectionview and datasource
                    }
                }
            }

            context("StreamCollectionViewLayoutDelegate") {

                it("is a StreamCollectionViewLayoutDelegate") {
                    expect(controller as StreamCollectionViewLayoutDelegate).notTo(beNil())
                }

                describe("collectionView(_:layout:sizeForItemAtIndexPath:)") {

                    context("one column layout") {

                        xit("returns the correct size for a Header Cell") {

                        }

                        xit("returns the correct size for a Comment Header Cell") {

                        }

                        xit("returns the correct size for a Footer Cell") {

                        }

                        xit("returns the correct size for an Image Cell") {

                        }

                        xit("returns the correct size for a Text Cell") {

                        }

                        xit("returns the correct size for a Comment Cell") {

                        }

                        xit("returns the correct size for a Profile Header Cell") {

                        }

                        xit("returns the correct size for a Notification Cell") {

                        }
                    }

                    context("two column layout") {

                        xit("returns the correct size for a Header Cell") {

                        }

                        xit("returns the correct size for a Comment Header Cell") {

                        }

                        xit("returns the correct size for a Footer Cell") {

                        }

                        xit("returns the correct size for an Image Cell") {

                        }

                        xit("returns the correct size for a Text Cell") {

                        }

                        xit("returns the correct size for a Comment Cell") {

                        }

                        xit("returns the correct size for a Profile Header Cell") {

                        }

                        xit("returns the correct size for a Notification Cell") {

                        }
                    }

                }

                describe("collectionView(_:layout:groupForItemAtIndexPath:)") {

                    xit("returns the same group for all cells in a post") {

                    }

                    xit("returns a different group for cells from different posts") {

                    }
                }

                describe("collectionView(_:layout:heightForItemAtIndexPath:numberOfColumns:)") {

                    context("one column layout") {

                        xit("returns the correct height for a Header Cell") {

                        }

                        xit("returns the correct height for a Comment Header Cell") {

                        }

                        xit("returns the correct height for a Footer Cell") {

                        }

                        xit("returns the correct height for an Image Cell") {

                        }

                        xit("returns the correct height for a Text Cell") {

                        }

                        xit("returns the correct height for a Comment Cell") {

                        }

                        xit("returns the correct height for a Profile Header Cell") {

                        }

                        xit("returns the correct height for a Notification Cell") {

                        }
                    }

                    context("two column layout") {

                        xit("returns the correct height for a Header Cell") {

                        }

                        xit("returns the correct height for a Comment Header Cell") {

                        }

                        xit("returns the correct height for a Footer Cell") {

                        }

                        xit("returns the correct height for an Image Cell") {

                        }

                        xit("returns the correct height for a Text Cell") {

                        }

                        xit("returns the correct height for a Comment Cell") {

                        }

                        xit("returns the correct height for a Profile Header Cell") {

                        }

                        xit("returns the correct height for a Notification Cell") {

                        }
                    }
                }

                describe("collectionView(_:layout:isFullWidthAtIndexPath:)") {

                    xit("returns false for a Header Cell") {

                    }

                    xit("returns false for a Comment Header Cell") {

                    }

                    xit("returns false for a Footer Cell") {

                    }

                    xit("returns false for an Image Cell") {

                    }

                    xit("returns false for a Text Cell") {

                    }

                    xit("returns false for a Comment Cell") {

                    }

                    xit("returns true for a Profile Header Cell") {

                    }

                    xit("returns false for a Notification Cell") {

                    }
                }
            }

            context("UIScrollViewDelegate") {

                it("is a UIScrollViewDelegate") {
                    expect(controller as UIScrollViewDelegate).notTo(beNil())
                }

                describe("scrollViewDidScroll(_:)") {

                    xit("hides the tab bar when scrolling up") {

                    }

                    xit("shows the tab bar when scrolling down") {

                    }
                }
            }

            context("responder chain") {
                it("reassigns next responder to PostbarController") {
                    expect(controller.next) === controller.postbarController
                }
            }
        }
    }
}
