////
///  InterfaceSpec.swift
//

@testable import Ello
import Quick
import Nimble
import SVGKit


class InterfaceSpec: QuickSpec {
    override func spec() {
        describe("Interface") {
            describe("Image") {
                describe("image(style:)") {
                    let styles: [(InterfaceImage, InterfaceImage.Style)] = [
                        (.elloLogo, .normal),
                        (.eye, .selected),
                        (.breakLink, .white),
                        (.angleBracket, .disabled),
                        (.x, .red),
                    ]
                    for (interfaceImage, style) in styles {
                        it("\(interfaceImage) should have style \(style)") {
                            expect(interfaceImage.image(style)).notTo(beNil())
                        }
                    }
                }

                describe("normalImage") {
                    let normalImages: [InterfaceImage] = [
                        .elloLogo,
                        .eye,
                        .heart,
                        .repost,
                        .share,
                        .xBox,
                        .pencil,
                        .reply,
                        .flag,
                        .comments,
                        .invite,
                        .sparkles,
                        .bolt,
                        .omni,
                        .person,
                        .circBig,
                        .narrationPointer,
                        .search,
                        .burger,
                        .gridView,
                        .listView,
                        .reorder,
                        .camera,
                        .check,
                        .arrow,
                        .link,
                        .breakLink,
                        .replyAll,
                        .bubbleBody,
                        .bubbleTail,
                        .whiteStar,
                        .blackStar,
                        .question,
                        .x,
                        .dots,
                        .plusSmall,
                        .checkSmall,
                        .angleBracket,
                        .audioPlay,
                        .videoPlay,
                        .validationLoading,
                        .validationError,
                        .validationOK,
                    ]
                    for image in normalImages {
                        it("\(image) should have a normalImage") {
                            expect(image.normalImage).notTo(beNil())
                        }
                    }
                }
                describe("selectedImage") {
                    let selectedImages: [InterfaceImage] = [
                        .eye,
                        .heart,
                        .repost,
                        .share,
                        .xBox,
                        .pencil,
                        .reply,
                        .flag,
                        .comments,
                        .invite,
                        .sparkles,
                        .bolt,
                        .omni,
                        .person,
                        .circBig,
                        .search,
                        .burger,
                        .reorder,
                        .camera,
                        .check,
                        .arrow,
                        .link,
                        .replyAll,
                        .bubbleBody,
                        .whiteStar,
                        .blackStar,
                        .x,
                        .dots,
                        .plusSmall,
                        .checkSmall,
                        .angleBracket,
                        .validationLoading,
                    ]
                    for image in selectedImages {
                        it("\(image) should have a selectedImage") {
                            expect(SVGKSourceLocalFile.internalSourceAnywhereInBundle(usingName: "\(image.rawValue)_selected.svg")).toNot(beNil())
                            expect(SVGKImage(named: "\(image.rawValue)_selected.svg").uiImage).toNot(beNil())
                        }
                    }
                }
                describe("whiteImage") {
                    let whiteImages: [InterfaceImage] = [
                        .breakLink,
                        .bubbleBody,
                        .camera,
                        .link,
                        .pencil,
                        .arrow,
                        .comments,
                        .heart,
                        .plusSmall,
                        .invite,
                        .repost
                    ]
                    for image in whiteImages {
                        it("\(image) should have a whiteImage") {
                            expect(SVGKSourceLocalFile.internalSourceAnywhereInBundle(usingName: "\(image.rawValue)_white.svg")).toNot(beNil())
                            expect(SVGKImage(named: "\(image.rawValue)_white.svg").uiImage).toNot(beNil())
                        }
                    }
                }
                describe("disabledImage") {
                    let disabledImages: [InterfaceImage] = [
                        .angleBracket,
                    ]
                    for image in disabledImages {
                        it("\(image) should have a disabledImage") {
                            expect(SVGKSourceLocalFile.internalSourceAnywhereInBundle(usingName: "\(image.rawValue)_disabled.svg")).toNot(beNil())
                            expect(SVGKImage(named: "\(image.rawValue)_disabled.svg").uiImage).toNot(beNil())
                        }
                    }
                }
                describe("redImage") {
                    let redImages: [InterfaceImage] = [
                        .x,
                    ]
                    for image in redImages {
                        it("\(image) should have a redImage") {
                            expect(SVGKSourceLocalFile.internalSourceAnywhereInBundle(usingName: "\(image.rawValue)_red.svg")).toNot(beNil())
                            expect(SVGKImage(named: "\(image.rawValue)_red.svg").uiImage).toNot(beNil())
                        }
                    }
                }
            }
        }
    }
}
