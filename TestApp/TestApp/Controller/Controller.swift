//
//  Controller.swift
//  TestApp
//
//  Created by Булат Сунгатуллин on 04.03.2020.
//  Copyright © 2020 Булат Сунгатуллин. All rights reserved.
//
import UIKit
import CoreLocation
import CoreBluetooth

class BeaconManager {
    
    var locationManager = CLLocationManager()
    var defaultUUID: String? 
    
    func getBeaconRegion(uuid: String) -> CLBeaconRegion {
        //0E1DFC63-1C6E-4E94-87A2-895A97267022
        let beaconRegion = CLBeaconRegion.init(uuid: UUID.init(uuidString: uuid)!, identifier:
            "com.tattelecom.Region")

        return beaconRegion
    }
    
    func startScanning(beaconRegion: CLBeaconRegion) {
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(satisfying: beaconRegion.beaconIdentityConstraint)
    }
    
    func checkValidUUID(uuidString: String) -> Bool {
        if UUID(uuidString: uuidString) != nil {
            return true
        } else {
            return false
        }
    }
    
    func filterModelArray(array: [Model]) -> [Model] {
        let filterArray = array.sorted(by: { $0.proximity < $1.proximity })
        return filterArray
    }
    
}

// MARK: First Controller extensions
extension FirstWindow {    
    func startScanning(refreshControll: UIRefreshControl) {
        if refreshControll.isRefreshing {
            bleArray.removeAll()
            self.centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
            
            let triggerTime = (Int64(NSEC_PER_SEC) * 2)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                if self.centralManager!.isScanning{
                    self.centralManager?.stopScan()
                }
            })
            refreshControll.endRefreshing()
        }
        
    }
    
}


extension FirstWindow: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {

        if beacons.count > 0 {
        
            for beacon in beacons {
                // check element in array
                let element = modelArray.contains { $0.uuid == beacon.uuid &&
                                                    $0.major == beacon.major &&
                                                    $0.minor == beacon.minor
                    
                }
                
                if element {
                    let indexElement = modelArray.firstIndex {  $0.uuid == beacon.uuid &&
                                                                $0.major == beacon.major &&
                                                                $0.minor == beacon.minor
                    }
                    modelArray[indexElement!] = Model(uuid: beacon.uuid, major: beacon.major, minor: beacon.minor, rssi: beacon.rssi, proximity: beacon.accuracy.binade)
                } else {
                    modelArray.append(Model(uuid: beacon.uuid, major: beacon.major, minor: beacon.minor, rssi: beacon.rssi, proximity: beacon.accuracy.binade))
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
           
        } else {
            modelArray.removeAll()
            //print("No beacons: \(beacons.count)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
}

extension FirstWindow: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning(refreshControll: myRefreshContoll)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print(peripheral)
        for (index, foundPeripheral) in bleArray.enumerated(){
            if foundPeripheral.peripheral?.identifier == peripheral.identifier{
                bleArray[index].lastRSSI = RSSI
                return
            }
        }
        
        let isConnectable = advertisementData["kCBAdvDataIsConnectable"] as! Bool
        let displayPeripheral = BleModel(peripheral: peripheral, lastRSSI: RSSI, isConnectable: isConnectable)
        bleArray.append(displayPeripheral)
        tableView.reloadData()
    }

}

