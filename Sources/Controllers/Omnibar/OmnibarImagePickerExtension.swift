////
///  OmnibarImagePickerExtension.swift
//

import Photos

extension OmnibarScreen: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func openImageSheet(_ imageSheetResult: ImagePickerSheetResult) {
        resignKeyboard()
        switch imageSheetResult {
        case let .controller(imageController):
            imageController.delegate = self
            delegate?.omnibarPresentController(imageController)
        case let .images(assets):
            processPHAssets(assets)
        }
    }

    fileprivate func processPHAssets(_ assets: [PHAsset], done: @escaping ElloEmptyCompletion = {}) {
        self.interactionEnabled = false
        AssetsToRegions.processPHAssets(assets) { (imageData: [ImageRegionData]) in
            self.interactionEnabled = true
            for imageDatum in imageData {
                let (image, imageData, type) = (imageDatum.image, imageDatum.data, imageDatum.contentType)
                self.addImage(image, data: imageData, type: type)
            }
            done()
        }
    }

    func imagePickerController(_ controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        func done() {
            self.delegate?.omnibarDismissController()
        }

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let url = info[UIImagePickerControllerReferenceURL] as? URL,
               let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject
            {
                processPHAssets([asset], done: done)
            }
            else {
                image.copyWithCorrectOrientationAndSize() { image in
                    self.addImage(image)
                    done()
                }
            }
        }
        else {
            done()
        }
    }

    func imagePickerControllerDidCancel(_ controller: UIImagePickerController) {
        delegate?.omnibarDismissController()
    }

    fileprivate func isGif(_ buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Bool {
        if length >= 4 {
            let isG = Int(buffer[0]) == 71
            let isI = Int(buffer[1]) == 73
            let isF = Int(buffer[2]) == 70
            let is8 = Int(buffer[3]) == 56

            return isG && isI && isF && is8
        }
        else {
            return false
        }
    }

}
