//
//  MemoriesSnapshot.swift
//  InstaWeather
//
//  Created by Besher on 2019-02-16.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

struct MemoriesSnapshotsArray: Codable {
    private var array: [MemoriesSnapshot] = [MemoriesSnapshot]()
    
    mutating func add(_ shot: MemoriesSnapshot) {
        array.insert(shot, at: 0)
    }
    
    func getMemories() -> [MemoriesSnapshot] {
        return array
    }
}

struct MemoriesSnapshot {
    let image: UIImage
    let date: Date
    
    static func addNewSnapshot(_ image: UIImage) {
        let newSnapshot = MemoriesSnapshot(image: image, date: Date())
        AppSettings.memoriesSnapshots.add(newSnapshot)
    }
}

extension MemoriesSnapshot: Codable {
    enum CodingKeys: String, CodingKey {
        case image
        case date
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.date = try container.decode(Date.self, forKey: .date)
        
        let imageData = try container.decode(Data.self, forKey: .image)
        self.image = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(imageData) as? UIImage ?? UIImage()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        let imageData = NSKeyedArchiver.archivedData(withRootObject: image)
        try container.encode(imageData, forKey: .image)
    }
}
