//
//  Item.swift
//  EXODUS 3 BEGINNER MODE
//
//  Created by Thomas Kane on 3/20/26.
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
