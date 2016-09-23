//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Sean on 1/27/16.
//  Copyright © 2016 Ello. All rights reserved.
//

import UIKit
import Social
import KeychainAccess
import SwiftyUserDefaults
import Moya
import Alamofire
import MobileCoreServices

public class ShareViewController: SLComposeServiceViewController {

    public var itemPreviews: [ExtensionItemPreview] = []
    private var postService = PostEditingService()
    private lazy var background: UIView = self.createBackground()

    // moved into a separate function to save compile time
    private func createBackground() -> UIView {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = .blackColor()
        view.frame = self.view.frame
        return view
    }

    public override func presentationAnimationDidFinish() {
        guard checkIfLoggedIn() else {
            return
        }

        processAttachments()

        super.presentationAnimationDidFinish()
    }

    public override func isContentValid() -> Bool {
        return ShareAttachmentProcessor.hasContent(contentText, extensionItem: extensionContext?.inputItems.safeValue(0) as? NSExtensionItem)
    }

    public override func didSelectPost() {
        showSpinner()
        let content = ShareRegionProcessor.prepContent(contentText, itemPreviews: itemPreviews)
        postContent(content)
    }
}

// MARK: Private
private extension ShareViewController {

    func processAttachments() {
        guard let extensionItem = extensionContext?.inputItems.safeValue(0) as? NSExtensionItem else {
            return
        }

        inBackground {
            ShareAttachmentProcessor.preview(extensionItem) { previews in
                inForeground {
                    self.itemPreviews = previews
                    self.isContentValid()
                }
            }
        }
    }

    func showSpinner() {
        view.addSubview(background)
        animate {
            self.background.alpha = 0.5
        }
        inForeground {
            ElloHUD.showLoadingHudInView(self.view)
        }
    }

    func postContent(content: [PostEditingService.PostContentRegion]) {
        postService.create(
            content: content,
            buyButtonURL: nil,
            success: { post in
//                Tracker.sharedTracker.shareSuccessful()
                self.donePosting()
                self.dismissPostingForm()
            },
            failure: { error, statusCode in
//                Tracker.sharedTracker.shareFailed()
                self.donePosting()
                self.showFailedToPost()
            }
        )
    }

    func donePosting() {
        inForeground {
            ElloHUD.hideLoadingHudInView(self.view)
            self.background.removeFromSuperview()
        }
    }

    func dismissPostingForm() {
        self.extensionContext?.completeRequestReturningItems([], completionHandler: nil)
    }

    func checkIfLoggedIn() -> Bool {
        if AuthToken().isPasswordBased {
            print("you are logged in")
        }
        else {
            showNotSignedIn()
        }
        return AuthToken().isPasswordBased
    }

    func showFailedToPost() {
        let message = InterfaceString.Share.FailedToPost
        let failedVC = AlertViewController(message: message)
        let cancelAction = AlertAction(title: InterfaceString.Cancel, style: .Light) {
            action in
            if let context = self.extensionContext {
                let error = NSError(domain: "co.ello.Ello", code: 0, userInfo: nil)
                context.cancelRequestWithError(error)
            }
        }

        let retryAction = AlertAction(title: InterfaceString.Retry, style: .Dark) {
            action in
            self.didSelectPost()
        }

        failedVC.addAction(retryAction)
        failedVC.addAction(cancelAction)
        self.presentViewController(failedVC, animated: true, completion: nil)
    }

    func showNotSignedIn() {
        let message = InterfaceString.Share.PleaseLogin
        let notSignedInVC = AlertViewController(message: message)
        let cancelAction = AlertAction(title: InterfaceString.OK, style: .Dark) {
            action in
            if let context = self.extensionContext {
                let error = NSError(domain: "co.ello.Ello", code: 0, userInfo: nil)
                context.cancelRequestWithError(error)
            }
        }

        notSignedInVC.addAction(cancelAction)
        self.presentViewController(notSignedInVC, animated: true, completion: nil)
    }
}
