//
//  MemoriesCache+CoreDataProperties.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-17.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//
//

import Foundation
import CoreData


extension MemoriesCache {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<MemoriesCache> {
        return NSFetchRequest<MemoriesCache>(entityName: "MemoriesCache")
    }

    @NSManaged public var date: Date
    @NSManaged public var imagedata: NSData

}
