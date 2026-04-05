//
//  Item.swift
//  Numbers 1 (Pupil)
//
//  Created by Thomas Kane on 4/3/26.
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
