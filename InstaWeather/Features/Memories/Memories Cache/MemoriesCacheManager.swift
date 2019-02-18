//
//  MemoriesCacheManager.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-17.
//  Copyright © 2019 Besher. All rights reserved.
//

import UIKit
import CoreData

struct MemoriesCacheManager {

    // enable to see Core Data activity
    static let debugLog = false

    private static var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MemoriesCacheModel")
        container.loadPersistentStores(completionHandler: { _, error in
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error { if debugLog {
                if debugLog { print("Unresolved Core Data error \(error.localizedDescription)") }
                }
            }
        })
        return container
    }()
    
    static func getDateForLastMemory() -> Date {
        let lastSnapshot = loadLastImageFromCache()
        return lastSnapshot?.date ?? Date()
    }

    static func loadMemory(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let image = loadImageFromCache(using: url.absoluteString) {
            // load locally
            if debugLog { print("CORE DATA: Successfully loaded image from Core Data!") }
            completion(image)
        }
    }
    
    static func loadAllMemories() -> [MemoriesSnapshot] {
        return loadAllImagesFromCache()
    }

    static func saveMemoryToCoreData(_ snapshot: MemoriesSnapshot) {
        guard let image = snapshot.image else { return }
        let date = snapshot.date
        if let imageData = image.jpegData(compressionQuality: 0.8) as NSData? {
            let imageCache = MemoriesCache(context: container.viewContext)
            imageCache.imagedata = imageData
            imageCache.date = date
            if debugLog { print("CORE DATA: Saving image locally!!") }
        }
        saveContext()
    }

}

// Core Data

extension MemoriesCacheManager {
    
    private static func loadAllImagesFromCache() -> [MemoriesSnapshot] {
        var memories = [MemoriesSnapshot]()
        
        let request = MemoriesCache.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            let cache = try container.viewContext.fetch(request)
            print("Got \(cache.count) memories")
            
            for memory in cache {
                if let data = memory.imagedata as Data?, let image = UIImage(data: data) {
                    let snapshot = MemoriesSnapshot(image: image, date: memory.date)
                    memories.append(snapshot)
                }
            }
            return memories
        } catch {
            print("Fetch failed. \(error.localizedDescription)")
        }
        return memories
    }
    
    private static func loadLastImageFromCache() -> MemoriesSnapshot? {
        
        let request = MemoriesCache.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            let cache = try container.viewContext.fetch(request)
            print("Got \(cache.count) memories")
            
            if let data = cache.first?.imagedata as Data?, let image = UIImage(data: data), let date = cache.first?.date {
                let snapshot = MemoriesSnapshot(image: image, date: date)
                return snapshot
            }
            
        } catch {
            print("Fetch failed. \(error.localizedDescription)")
        }
        return nil
    }

    private static func loadImageFromCache(using date: String) -> UIImage? {
        let predicate: NSPredicate = NSPredicate(format: "url == %@", date)

        var result = [MemoriesCache]()
        let request = MemoriesCache.createFetchRequest()
        request.predicate = predicate
        do {
            result = try container.viewContext.fetch(request)
            if debugLog { print("CORE DATA: Successfully fetched object!") }
        } catch {
            if debugLog { print("CORE DATA: IMAGE FETCH FAILED") }
        }

        if let imageData = result.first?.imagedata as Data?,
            let image = UIImage(data: imageData) {

            if debugLog { print("CORE DATA: Successfully returning image! Dated \(String(describing: result.first?.date))") }
            return image
        } else {
            return nil
        }
    }

    private static func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                if debugLog { print("An error occured while saving: \(error)") }
            }
        }
    }
}
