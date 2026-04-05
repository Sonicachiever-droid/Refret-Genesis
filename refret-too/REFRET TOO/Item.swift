//
//  Item.swift
//  REFRET TOO
//
//  Created by Thomas Kane on 3/10/26.
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
