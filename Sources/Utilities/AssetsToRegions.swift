////
///  AssetsToRegions.swift
//

import Photos


public struct AssetsToRegions {

    public static func processPHAssets(assets: [PHAsset], completion: ([ImageRegionData]) -> Void) {
        nextPHAsset(assets, stack: [], completion: completion)
    }

    private static func nextPHAsset(assets: [PHAsset], stack: [ImageRegionData], completion: ([ImageRegionData]) -> Void) {
        guard let asset = assets.first else {
            completion(stack)
            return
        }
        var newStack = stack

        func done() {
            nextPHAsset(Array<PHAsset>(assets[1..<assets.count]), stack: newStack, completion: completion)
        }

        var image: UIImage?
        var imageData: NSData?
        let imageAndData = after(2) {
            guard let image = image, imageData = imageData else {
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
        options.deliveryMode = .HighQualityFormat

        PHImageManager.defaultManager().requestImageForAsset(
            asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .Default,
            options: options
        ) { phImage, info in
            image = phImage
            imageAndData()
        }

        PHImageManager.defaultManager().requestImageDataForAsset(
            asset,
            options: nil
        ) { phData, dataUTI, orientation, info in
            imageData = phData
            imageAndData()
        }

    }

}
