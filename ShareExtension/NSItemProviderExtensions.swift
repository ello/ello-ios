////
///  NSItemProviderExtensions.swift
//

import Foundation
import MobileCoreServices

extension NSItemProvider {

    func isURL() -> Bool {
        return self.hasItemConformingToTypeIdentifier(String(kUTTypeURL))
    }
    func isImage() -> Bool {
        return self.hasItemConformingToTypeIdentifier(String(kUTTypeImage))
    }

    func isText() -> Bool {
        return self.hasItemConformingToTypeIdentifier(String(kUTTypeText))
    }

    func loadText(_ options: [AnyHashable: Any]?, completion: NSItemProvider.CompletionHandler?) {
        self.loadItem(forTypeIdentifier: String(kUTTypeText), options: options, completionHandler: completion)
    }

    func loadURL(_ options: [AnyHashable: Any]?, completion: NSItemProvider.CompletionHandler?) {
        self.loadItem(forTypeIdentifier: String(kUTTypeURL), options: options, completionHandler: completion)
    }

    func loadPreview(_ options: [AnyHashable: Any]!, completion: NSItemProvider.CompletionHandler!) {
        self.loadPreviewImage(options: options, completionHandler: completion)
    }

    func loadImage(_ options: [AnyHashable: Any]!, completion: NSItemProvider.CompletionHandler!) {
        self.loadItem(forTypeIdentifier: String(kUTTypeImage), options: options, completionHandler: completion)
    }
}
