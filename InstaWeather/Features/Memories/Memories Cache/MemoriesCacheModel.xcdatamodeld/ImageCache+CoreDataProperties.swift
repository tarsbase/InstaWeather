//
//  ImageCache+CoreDataProperties.swift
//  Find My Latte
//
//  Created by Besher on 2018-09-20.
//  Copyright © 2018 Besher. All rights reserved.
//
//

import Foundation
import CoreData

extension ImageCache {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<ImageCache> {
        return NSFetchRequest<ImageCache>(entityName: "ImageCache")
    }

    @NSManaged public var imagedata: NSData
    @NSManaged public var url: String
    @NSManaged public var date: Date

}
