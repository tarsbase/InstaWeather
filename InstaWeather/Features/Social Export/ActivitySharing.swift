//
//  ActivitySharing.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-13.
//  Copyright © 2019 Besher. All rights reserved.
//

import UIKit

class TextProvider: NSObject, UIActivityItemSource {

    var subject = "InstaWeather"
    var url: URL = URL(string: LiveInstance.shortAppStoreURL)!

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return NSObject()
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if activityType == .postToTwitter {
            return "Download #InstaWeather via @BesherMaleh"
        } else if activityType == .postToFacebook {
            return url
        } else {
            return "Download #InstaWeather at \(url)"
        }
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return subject
    }
}

class ImageProvider: NSObject, UIActivityItemSource {

    var image = UIImage()

    init(image: UIImage) {
        self.image = image
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return image
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return image
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "InstaWeather"
    }
}

struct ShareDocumentHost {
    
    private init(){}
    
    static func share(_ image: UIImage?, by viewController: UIViewController?) {
        guard let image = image, let viewController = viewController else { return }
        let vc = UIActivityViewController(activityItems: [ImageProvider(image: image), TextProvider()], applicationActivities: [])
        viewController.present(vc, animated: true)
    }
}
