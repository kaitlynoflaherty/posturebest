//
//  Peripheral.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 10/2/24.
//

import Foundation

struct Peripheral: Identifiable {
    let id: UUID
    let name: String
    let rssi: Int // used for signal strength
}
