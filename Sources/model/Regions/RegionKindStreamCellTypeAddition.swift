////
///  RegionKindStreamCellTypeAddition.swift
//

import Foundation

extension RegionKind {
    func streamCellTypes(_ regionable: Regionable) -> [StreamCellType] {
        switch self {
        case .image:
            return [.image(data: regionable)]
        case .text:
            if let textRegion = regionable as? TextRegion {
                let content = textRegion.content
                let paragraphs = content.components(separatedBy: "</p>")
                return paragraphs.flatMap { (para: String) -> StreamCellType? in
                    if para == "" {
                        return nil
                    }

                    let newRegion = TextRegion(content: para + "</p>")
                    newRegion.isRepost = textRegion.isRepost
                    return .text(data: newRegion)
                }
            }
            return []
        case .embed:
            return [.embed(data: regionable)]
        case .unknown:
            return [.unknown]
        }
    }
}
