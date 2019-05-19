//
//  SocialStack.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-13.
//  Copyright © 2019 Besher. All rights reserved.
//

import UIKit
import FBSDKShareKit
import TwitterKit
import SCSDKCreativeKit
import SafariServices

class SocialExport: NSObject, SharingDelegate {
    

    enum AnchorSide {
        case top, bottom
    }
    
    private weak var vcDelegate: UIViewController?
    private weak var sourceButton: UIView?
    private var anchor: UIView
    private var instagramShareFile: UIDocumentInteractionController?
    private var image: UIImage?
    
    init(delegate: UIViewController, source: UIView, image: UIImage?, anchorSide: AnchorSide) {
        self.vcDelegate = delegate
        self.sourceButton = source
        
        let anchor = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        anchor.center.x = source.center.x
        anchor.frame.origin.y = anchorSide == .bottom ? source.frame.maxY : source.frame.minY
        self.anchor = anchor
        vcDelegate?.view.addSubview(anchor)
        
        self.image = image
    }

    private func getSocialMessage() -> String {
        return "#InstaWeather"
    }
    
    func showAlert() {
        
        let ac = UIAlertController(title: "Share image", message: nil, preferredStyle: .actionSheet)
        ac.popoverPresentationController?.sourceView = anchor
        ac.popoverPresentationController?.permittedArrowDirections = [.up, .down]
        
        
        ac.addAction(UIAlertAction(title: "Facebook", style: .default, handler: { [weak self] _ in
            self?.facebookShare()
        }))
        
        ac.addAction(UIAlertAction(title: "Instagram", style: .default, handler: { [weak self] _ in
            self?.instagramShare()
        }))
        
        ac.addAction(UIAlertAction(title: "Twitter", style: .default, handler: { [weak self] _ in
            self?.twitterShare()
        }))
        
        ac.addAction(UIAlertAction(title: "Snapchat", style: .default, handler: { [weak self] _ in
            self?.snapchatShare()
        }))
        
        ac.addAction(UIAlertAction(title: "Other...", style: .default, handler: { [weak self] _ in
            ShareDocumentHost.share(self?.image, by: self?.vcDelegate, source: self?.anchor)
        }))
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        vcDelegate?.present(ac, animated: true)
    }

    // MARK: - Facebook

    private func facebookShare() {
        AnalyticsEvents.logEvent(.exportFacebook)
        if (UIApplication.shared.canOpenURL(URL(string: "fb://")!)) {
            nativePhotoFacebookSheet()
        } else {
            launchAppStorePage(for: .facebook)
        }
    }

    private func nativePhotoFacebookSheet() {

        guard let imageToShare = image else {
            return // No image selected.
        }

        let imageContent = SharePhoto(image: imageToShare, userGenerated: true)
        let content = SharePhotoContent()
        content.photos = [imageContent]
        content.hashtag = Hashtag("#InstaWeather")
        
        let dialog = ShareDialog()
        dialog.shareContent = content
        dialog.fromViewController = vcDelegate
        dialog.mode = ShareDialog.Mode.shareSheet
        dialog.delegate = self
        dialog.show()
        
    }

    func sharer(_ sharer: Sharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
        //TODO stop loading animation
        print("Finished loading")
    }

    
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        // TODO
    }
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        // TODO
    }

    // MARK: - Twitter
    func twitterShare() {
        AnalyticsEvents.logEvent(.exportTwitter)
        if UIApplication.shared.canOpenURL(URL(string: "twitter://app")!) {
            shareTwitter()
        } else {
            launchAppStorePage(for: .twitter)
        }
    }

    private func shareTwitter() {
        guard let image = image else { return }
        let composer = TWTRComposer()
        composer.setURL(URL(string: LiveInstance.shortAppStoreURL))
        composer.setText(getSocialMessage())
        composer.setImage(image)

        // Called from a UIViewController
        composer.show(from: (vcDelegate!)) { result in
            if (result == .done) {
                print("Successfully composed Tweet")
            } else {
                print("Cancelled composing")
            }
        }
    }

}

extension SocialExport: UIDocumentInteractionControllerDelegate {

    // MARK: - Instagram

    private func instagramShare() {
        AnalyticsEvents.logEvent(.exportInstagram)
        if UIApplication.shared.canOpenURL(URL(string: "instagram://app")!) {
            shareInstagram()
        } else {
            launchAppStorePage(for: .instagram)
        }
    }

    private func shareInstagram() {
        guard let image = image, let vcDelegate = vcDelegate else { return }

        let imageData = image.jpegData(compressionQuality: 100)
        let writePath = (NSTemporaryDirectory() as NSString).appendingPathComponent("instagram.igo")
        let caption = getSocialMessage()
        do {
            try imageData?.write(to: URL(fileURLWithPath: writePath), options: .atomic)
        } catch {
            print(error)
        }

        let fileURL = URL(fileURLWithPath: writePath)

        self.instagramShareFile = UIDocumentInteractionController(url: fileURL)
        self.instagramShareFile?.delegate = self
        self.instagramShareFile?.uti = "com.instagram.exlusivegram"
        self.instagramShareFile?.annotation = ["InstagramCaption": caption]

        if UIDevice.current.userInterfaceIdiom == .phone {
            self.instagramShareFile?.presentOpenInMenu(from: vcDelegate.view.bounds, in: vcDelegate.view, animated: true)
        } else {
            self.instagramShareFile?.presentOpenInMenu(from: anchor.frame, in: vcDelegate.view, animated: true)
        }
    }

}

extension SocialExport {

    // MARK: - SnapChat

    private func snapchatShare() {
        AnalyticsEvents.logEvent(.exportSnapchat)
        if UIApplication.shared.canOpenURL(URL(string: "snapchat://app")!) {
            snapchatCreativeShare()
        } else {
            launchAppStorePage(for: .snapchat)
        }
    }

    private func snapchatCreativeShare() {

        guard let image = image else { return }

        let photo = SCSDKSnapPhoto(image: image)
        let photoContent = SCSDKPhotoSnapContent(snapPhoto: photo)

        photoContent.caption = getSocialMessage()
        photoContent.attachmentUrl = LiveInstance.shortAppStoreURL

        let api = SCSDKSnapAPI(content: photoContent)
        api.startSnapping { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - StoreProduct Delegate

extension SocialExport {
    
    private func launchAppStorePage(for app: AppStoreAppsKeys) {
        if let url = URL(string: app.url) {
            let config = SFSafariViewController.Configuration()
            let vc = SFSafariViewController(url: url, configuration: config)
            vc.modalPresentationStyle = .pageSheet
            vcDelegate?.present(vc, animated: true)
        }
    }
}
