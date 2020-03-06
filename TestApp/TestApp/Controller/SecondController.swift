//
//  SecondController.swift
//  TestApp
//
//  Created by Булат Сунгатуллин on 06.03.2020.
//  Copyright © 2020 Булат Сунгатуллин. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

extension SecondWindow: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {

        if beacons.count > 0 {
            for beacon in beacons {
                // check element in array
                let element = ibeacons.contains { $0.uuid == beacon.uuid &&
                                                    $0.major == beacon.major &&
                                                    $0.minor == beacon.minor
                    
                }
                
                if element {
                    let indexElement = ibeacons.firstIndex {  $0.uuid == beacon.uuid &&
                                                                $0.major == beacon.major &&
                                                                $0.minor == beacon.minor
                    }
                    ibeacons[indexElement!] = Model(uuid: beacon.uuid, major: beacon.major, minor: beacon.minor, rssi: beacon.rssi, proximity: beacon.accuracy.binade)
                } else {
                    ibeacons.append(Model(uuid: beacon.uuid, major: beacon.major, minor: beacon.minor, rssi: beacon.rssi, proximity: beacon.accuracy.binade))
                }
                
                if typeDevice == "iBeacon" {
                    let newModel = searchModel(model: beconModel!)
                    setParamBeacon(findModel: newModel)
                }
            }
           
        } else {
            ibeacons.removeAll()
        }
    }
}
