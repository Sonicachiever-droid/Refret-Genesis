//
//  Item.swift
//  EXODUS 3 LANDSCAPE
//
//  Created by Thomas Kane on 3/19/26.
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
