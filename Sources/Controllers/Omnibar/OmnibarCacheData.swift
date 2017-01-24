////
///  OmnibarCacheData.swift
//

class OmnibarCacheData: NSObject, NSCoding {
    var regions: [NSObject]

    override init() {
        regions = [NSObject]()
        super.init()
    }

// MARK: NSCoding

    func encode(with encoder: NSCoder) {
        encoder.encode(regions, forKey: "regions")
    }

    required init?(coder: NSCoder) {
        let decoder = Coder(coder)
        regions = decoder.decodeKey("regions")
        super.init()
    }

}
