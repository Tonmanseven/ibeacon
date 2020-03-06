//
//  Model.swift
//  TestApp
//
//  Created by Булат Сунгатуллин on 05.03.2020.
//  Copyright © 2020 Булат Сунгатуллин. All rights reserved.
//

import Foundation
import CoreBluetooth

struct Model {
    let uuid: UUID
    let major: NSNumber
    let minor: NSNumber
    let rssi: Int
    let proximity: Double
}

struct BleModel {
    var peripheral: CBPeripheral?
    var lastRSSI: NSNumber?
    var isConnectable: Bool?
}
