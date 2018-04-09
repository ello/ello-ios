////
///  CategoryGeneratorSpec.swift
//

@testable import Ello
import Quick
import Nimble

class CategoryGeneratorSpec: QuickSpec {
    override func spec() {
        describe("CategoryGenerator") {
            var destination: CategoryDestination!
            var currentUser: User!
            var category: Ello.Category!
            var subject: CategoryGenerator!

            beforeEach {
                destination = CategoryDestination()
                currentUser = User.stub(["id": "42"])
            }

            beforeEach {
                category = Ello.Category.stub(["level": "meta", "slug": "recommended"])
                subject = CategoryGenerator(
                    selection: .category(category.slug),
                    filter: .featured,
                    currentUser: currentUser,
                    destination: destination
                )
            }

            describe("load()") {
                beforeEach {
                    StubbedManager.current.addStub { request, sender in
                        guard
                            let sender = sender as? GraphQLRequest<[PageHeader]>,
                            sender.endpointName == "pageHeaders"
                        else { return nil }

                        return stubbedData("pageHeaders")
                    }

                    StubbedManager.current.addStub { request, sender in
                        guard
                            let sender = sender as? GraphQLRequest<[Ello.Category]>,
                            sender.endpointName == "categoryNav"
                        else { return nil }

                        return stubbedData("categoryNav")
                    }

                    StubbedManager.current.addStub { request, sender in
                        guard
                            let sender = sender as? GraphQLRequest<(PageConfig, [Post])>
                        else { return nil }

                        if sender.endpointName == "subscribedPostStream" {
                            return stubbedData("subscribedPostStream")
                        }
                        else if sender.endpointName == "globalPostStream" {
                            return stubbedData("globalPostStream")
                        }
                        else if sender.endpointName == "categoryPostStream" {
                            return stubbedData("categoryPostStream")
                        }
                        else {
                            return nil
                        }
                    }
                }

                it("sets 2 placeholders") {
                    subject.load(reloadPosts: false, reloadHeader: false, reloadCategories: false)
                    expect(destination.placeholderItems.count) == 2
                }

                it("replaces only CatgoryHeader and CategoryPosts") {
                    subject.load(reloadPosts: false, reloadHeader: false, reloadCategories: false)
                    expect(destination.headerItems.count) > 0
                    expect(destination.postItems.count) > 0
                    expect(destination.otherPlaceHolderLoaded) == false
                }

                it("sets the primary jsonable") {
                    subject.load(reloadPosts: false, reloadHeader: false, reloadCategories: false)
                    expect(destination.pageHeader).toNot(beNil())
                }

                it("sets the categories") {
                    subject.load(reloadPosts: false, reloadHeader: false, reloadCategories: false)
                    expect(destination.subscribedCategories.count) > 0
                }

                it("sets the config response") {
                    subject.load(reloadPosts: false, reloadHeader: false, reloadCategories: false)
                    expect(destination.responseConfig).toNot(beNil())
                }
            }
        }
    }
}

class CategoryDestination: CategoryStreamDestination {
    var placeholderItems: [StreamCellItem] = []
    var headerItems: [StreamCellItem] = []
    var postItems: [StreamCellItem] = []
    var otherPlaceHolderLoaded = false
    var subscribedCategories: [Ello.Category] = []
    var pageHeader: PageHeader?
    var responseConfig: ResponseConfig?
    var isPagingEnabled: Bool = false

    func setPlaceholders(items: [StreamCellItem]) {
        placeholderItems = items
    }

    func replacePlaceholder(type: StreamCellType.PlaceholderType, items: [StreamCellItem], completion: @escaping Block) {
        switch type {
        case .promotionalHeader:
            headerItems = items
        case .streamItems:
            postItems = items
        default:
            otherPlaceHolderLoaded = true
        }
    }

    func setPrimary(jsonable: JSONAble) {
        self.pageHeader = jsonable as? PageHeader
    }

    func set(subscribedCategories: [Ello.Category]) {
        self.subscribedCategories = subscribedCategories
    }

    func primaryJSONAbleNotFound() {
    }

    func setPagingConfig(responseConfig: ResponseConfig) {
        self.responseConfig = responseConfig
    }
}
