////
///  ShareRegionProcessor.swift
//

class ShareRegionProcessor {

    static func prepContent(_ contentText: String, itemPreviews: [ExtensionItemPreview]) -> [PostEditingService.PostContentRegion] {
        var content: [PostEditingService.PostContentRegion] = []

        let cleanedText = contentText.trimmingCharacters(in: CharacterSet.whitespaces)
        if !cleanedText.isEmpty {
            let region = PostEditingService.PostContentRegion.text(cleanedText)
            let exists = content.any {$0 == region}
            if !exists {
                content.append(region)
            }
        }

        for preview in itemPreviews {
            if let gifData = preview.gifData, let image = preview.image {
                let region = PostEditingService.PostContentRegion.imageData(image, gifData, "image/gif")
                let exists = content.any {$0 == region}
                if !exists {
                    content.append(region)
                }
            }
            else if let image = preview.image {
                let region = PostEditingService.PostContentRegion.image(image)
                let exists = content.any {$0 == region}
                if !exists {
                    content.append(region)
                }
            }

            if let text = preview.text {
                let region = PostEditingService.PostContentRegion.text(text)
                let exists = content.any {$0 == region}
                if !exists {
                    content.append(region)
                }
            }
        }

        return content
    }
}
