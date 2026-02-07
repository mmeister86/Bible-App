//
//  Item.swift
//  Bible App
//
//  Created by Matthias Meister on 07.02.26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
