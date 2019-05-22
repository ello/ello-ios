////
///  PINRemoteImageManagerResult.swift
//

import PINRemoteImage

public extension PINRemoteImageManagerResult {

    var animatedImage: PINCachedAnimatedImage? {
        return alternativeRepresentation as? PINCachedAnimatedImage
    }

    var isAnimated: Bool {
        return animatedImage != nil
    }

    var imageSize: CGSize? {
        return isAnimated ? animatedImage?.size : image?.size
    }

    var hasImage: Bool {
        return image != nil || animatedImage != nil
    }
}
