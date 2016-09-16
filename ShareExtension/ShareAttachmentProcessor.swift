////
///  ShareAttachmentProcessor.swift
//

import Foundation
import UIKit

public typealias ExtensionItemProcessor = ExtensionItemPreview? -> Void
public typealias ShareAttachmentFilter = (ExtensionItemPreview) -> Bool

public class ShareAttachmentProcessor {

    public init(){}

    static public func preview(extensionItem: NSExtensionItem, callback: [ExtensionItemPreview] -> Void) {
        var previews: [ExtensionItemPreview] = []
        processAttachments(0, attachments: extensionItem.attachments as? [NSItemProvider] , previews: &previews, callback: callback)
    }

    static public func hasContent(contentText: String?, extensionItem: NSExtensionItem?) -> Bool {
        let cleanedText = contentText?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if cleanedText?.characters.count > 0 {
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
        index: Int,
        attachments: [NSItemProvider]?,
        inout previews: [ExtensionItemPreview],
        callback: [ExtensionItemPreview] -> Void)
    {
        if let attachment = attachments?.safeValue(index) {
            processAttachment(attachment) { preview in
                if let preview = preview {
                    let exists = previews.any {$0 == preview}
                    if !exists {
                        previews.append(preview)
                    }
                }
                self.processAttachments(
                    index + 1,
                    attachments: attachments,
                    previews: &previews,
                    callback: callback
                )
            }
        }
        else {
            callback(previews)
        }
    }

    static func processAttachment( attachment: NSItemProvider, callback: ExtensionItemProcessor) {
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

    static func processText(attachment: NSItemProvider, callback: ExtensionItemProcessor) {
        attachment.loadText(nil) { (item, error) in
            var preview: ExtensionItemPreview?
            if let item = item as? String {
                preview = ExtensionItemPreview(text: item)
            }
            callback(preview)
        }
    }

    static func processURL(attachment: NSItemProvider, callback: ExtensionItemProcessor) {
        attachment.loadURL(nil) {
            (item, error) in
            var link: String?
            if let item = item as? NSURL {
                link = item.absoluteString
            }
            let item = ExtensionItemPreview(text: link)
            callback(item)
        }
    }

    static func processImage(attachment: NSItemProvider, callback: ExtensionItemProcessor) {
        attachment.loadImage(nil) {
            (imageItem, error) in
            if let imageURL = imageItem as? NSURL {
                var data: NSData? = NSData(contentsOfURL: imageURL)
                if data == nil {
                    if let imageString = imageURL.absoluteString {
                        data = NSData(contentsOfFile: imageString)
                    }
                }
                if let imageData = data {
                    processData(imageData, callback)
                }
            }
            else if let imageData = imageItem as? NSData {
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

    static func processData(data: NSData, _ callback: ExtensionItemProcessor) {
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

    static func processImage(image: UIImage, _ callback: ExtensionItemProcessor) {
        image.copyWithCorrectOrientationAndSize() { image in
            let item = ExtensionItemPreview(image: image)
            callback(item)
        }
    }
}
