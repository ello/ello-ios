////
///  ShareAttachmentProcessor.swift
//

import Foundation
import UIKit


typealias ExtensionItemProcessor = (ExtensionItemPreview?) -> Void
typealias ShareAttachmentFilter = (ExtensionItemPreview) -> Bool

class ShareAttachmentProcessor {

    init(){}

    static func preview(_ extensionItem: NSExtensionItem, callback: @escaping ([ExtensionItemPreview]) -> Void) {
        let previews: [ExtensionItemPreview] = []
        processAttachments(0, attachments: extensionItem.attachments as? [NSItemProvider] , previews: previews, callback: callback)
    }

    static func hasContent(_ contentText: String?, extensionItem: NSExtensionItem?) -> Bool {
        let cleanedText = contentText?.trimmingCharacters(in: CharacterSet.whitespaces)
        if let count = cleanedText?.characters.count, count > 0 {
            return true
        }

        guard let extensionItem = extensionItem else {
            return false
        }

        if let attachments = extensionItem.attachments as? [NSItemProvider] {
            for attachment in attachments {
                if attachment.isImage() || attachment.isURL() || attachment.isImage() {
                    return true
                }
            }
        }
        return false
    }
}


// MARK: Private

private extension ShareAttachmentProcessor {

    static func processAttachments(
        _ index: Int,
        attachments: [NSItemProvider]?,
        previews: [ExtensionItemPreview],
        callback: @escaping ([ExtensionItemPreview]) -> Void)
    {
        if let attachment = attachments?.safeValue(index) {
            processAttachment(attachment) { preview in
                var previewsCopy = previews
                if let preview = preview {
                    let exists = previews.any {$0 == preview}
                    if !exists {
                        previewsCopy.append(preview)
                    }
                }
                self.processAttachments(
                    index + 1,
                    attachments: attachments,
                    previews: previewsCopy,
                    callback: callback
                )
            }
        }
        else {
            callback(previews)
        }
    }

    static func processAttachment( _ attachment: NSItemProvider, callback: @escaping ExtensionItemProcessor) {
        if attachment.isText() {
            self.processText(attachment, callback: callback)
        }
        else if attachment.isImage() {
            self.processImage(attachment, callback: callback)
        }
        else if attachment.isURL() {
            self.processURL(attachment, callback: callback)
        }
        else {
            callback(nil)
        }
    }

    static func processText(_ attachment: NSItemProvider, callback: @escaping ExtensionItemProcessor) {
        attachment.loadText(nil) { (item, error) in
            var preview: ExtensionItemPreview?
            if let item = item as? String {
                preview = ExtensionItemPreview(text: item)
            }
            callback(preview)
        }
    }

    static func processURL(_ attachment: NSItemProvider, callback: @escaping ExtensionItemProcessor) {
        attachment.loadURL(nil) {
            (item, error) in
            var link: String?
            if let item = item as? URL {
                link = item.absoluteString
            }
            let item = ExtensionItemPreview(text: link)
            callback(item)
        }
    }

    static func processImage(_ attachment: NSItemProvider, callback: @escaping ExtensionItemProcessor) {
        attachment.loadImage(nil) {
            (imageItem, error) in
            if let imageURL = imageItem as? URL {
                var data: Data? = try? Data(contentsOf: imageURL)
                if data == nil {
                    data = try? Data(contentsOf: URL(fileURLWithPath: imageURL.absoluteString))
                }
                if let imageData = data {
                    processData(imageData, callback)
                }
            }
            else if let imageData = imageItem as? Data {
                processData(imageData, callback)
            }
            else if let image = imageItem as? UIImage {
                processImage(image, callback)
            }
            else {
                callback(nil)
            }
        }
    }

    static func processData(_ data: Data, _ callback: @escaping ExtensionItemProcessor) {
        if let image = UIImage(data: data) {
            if UIImage.isGif(data) {
                image.copyWithCorrectOrientationAndSize() { image in
                    let item = ExtensionItemPreview(image: image, gifData: data)
                    callback(item)
                }
            }
            else {
                processImage(image, callback)
            }
        }
        else {
            callback(nil)
        }
    }

    static func processImage(_ image: UIImage, _ callback: @escaping ExtensionItemProcessor) {
        image.copyWithCorrectOrientationAndSize() { image in
            let item = ExtensionItemPreview(image: image)
            callback(item)
        }
    }
}
