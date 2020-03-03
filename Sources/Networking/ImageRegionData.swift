////
///  ImageRegionData.swift
//

struct ImageRegionData {
    let image: UIImage
    let data: Data?
    let contentType: String?
    let buyButtonURL: URL?

    var isAnimatedGif: Bool { return contentType == "image/gif" }

    init(image: UIImage, buyButtonURL: URL? = nil) {
        self.image = image
        self.data = nil
        self.contentType = nil
        self.buyButtonURL = buyButtonURL
    }

    init(image: UIImage, data: Data, contentType: String, buyButtonURL: URL? = nil) {
        self.image = image
        self.data = data
        self.contentType = contentType
        self.buyButtonURL = buyButtonURL
    }

    static func == (lhs: ImageRegionData, rhs: ImageRegionData) -> Bool {
        guard lhs.image == rhs.image else { return false }

        if let lhData = lhs.data, let rhData = rhs.data, let lhContentType = lhs.contentType,
            let rhContentType = rhs.contentType
        {
            return lhData == rhData && lhContentType == rhContentType
        }
        return true
    }

}

extension ImageRegionData: Equatable {}
