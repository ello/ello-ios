////
///  AssetsToRegions.swift
//

import Photos


struct AssetsToRegions {

    static func processPHAssets(_ assets: [PHAsset], completion: @escaping ([ImageRegionData]) -> Void) {
        nextPHAsset(assets, stack: [], completion: completion)
    }

    fileprivate static func nextPHAsset(_ assets: [PHAsset], stack: [ImageRegionData], completion: @escaping ([ImageRegionData]) -> Void) {
        guard let asset = assets.first else {
            completion(stack)
            return
        }
        var newStack = stack

        func done() {
            nextPHAsset(Array<PHAsset>(assets[1..<assets.count]), stack: newStack, completion: completion)
        }

        var image: UIImage?
        var imageData: Data?
        let imageAndData = after(2) {
            guard let image = image, let imageData = imageData else {
                done()
                return
            }

            if UIImage.isGif(imageData) {
                newStack.append(ImageRegionData(image: image, data: imageData, contentType: "image/gif", buyButtonURL: nil))
                done()
            }
            else {
                image.copyWithCorrectOrientationAndSize() { orientedImage in
                    if let image = orientedImage {
                        newStack.append(ImageRegionData(image: image, buyButtonURL: nil))
                    }
                    done()
                }
            }
        }
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat

        PHImageManager.default().requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { phImage, info in
            image = phImage
            imageAndData()
        }

        PHImageManager.default().requestImageData(
            for: asset,
            options: nil
        ) { phData, dataUTI, orientation, info in
            imageData = phData
            imageAndData()
        }

    }

}
