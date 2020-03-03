////
///  UIImagePickerControllerSpec.swift
//

@testable import Ello
import Quick
import Nimble


class UIImagePickerControllerSpec: QuickSpec {
    override func spec() {
        describe("UIImagePickerController") {
            describe("alertControllerForImagePicker") {
                it("should present the photo library if no camera is available") {
                    var imagePickerController: UIImagePickerController?
                    let subject = UIImagePickerController.alertControllerForImagePicker {
                        presentedPicker in
                        imagePickerController = presentedPicker
                    }
                    expect(subject).to(beNil())
                    expect(imagePickerController).toNot(beNil())
                }
            }

            describe("imagePickerSheetForImagePicker") {
                it("should present an image picker with actions") {
                    let subject = UIImagePickerController.imagePickerSheetForImagePicker(callback: {
                        _ in
                    })
                    expect(subject.actions.count) > 0
                }
            }
        }
    }
}
