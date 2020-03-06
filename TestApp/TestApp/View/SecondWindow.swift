//
//  SecondWindow.swift
//  TestApp
//
//  Created by Булат Сунгатуллин on 04.03.2020.
//  Copyright © 2020 Булат Сунгатуллин. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class SecondWindow: UIViewController {

    @IBOutlet weak var typeDeviceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    private let controller = BeaconManager()

    var beconModel: Model? = nil
    var bleModel: BleModel? = nil
    var modelUUID = "0E1DFC63-1C6E-4E94-87A2-895A97267022"
    var typeDevice: String?
    private var nameDevice: String?
    private var rssi: String?
    private var major: String?
    private var minor: String?
    private var distance: String?
    
    var ibeacons = [Model]()

    var instanseOfAllVC: FirstWindow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Подробнее"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        modelUUID = beconModel?.uuid.uuidString ?? "0E1DFC63-1C6E-4E94-87A2-895A97267022"
        updateValues(uuid: modelUUID)
        if typeDevice == "BLE" {setParamBle()}
    }
    
    
    func updateValues(uuid: String) {
        controller.locationManager = CLLocationManager.init()
        controller.locationManager.delegate = self
        controller.locationManager.requestWhenInUseAuthorization()
        controller.startScanning(beaconRegion: controller.getBeaconRegion(uuid: uuid))
    }
    
    func setParamBeacon(findModel: Model) {
        typeDeviceLabel.text = typeDevice
        nameLabel.text = "UUID: " + findModel.uuid.uuidString
        rssiLabel.text = "RSSI: " + String(findModel.rssi) + " dBm"
        majorLabel.text = "major: " + findModel.major.stringValue
        minorLabel.text = "minor: " + findModel.minor.stringValue
        distanceLabel.text = "Дистанция: " + String(findModel.proximity) + " м"
    }
    
    func setParamBle() {
        typeDeviceLabel.text = typeDevice
        nameLabel.text = "Device: " + (bleModel?.peripheral?.name ?? "Unknown")
        rssiLabel.text = "RSSI: " + (bleModel?.lastRSSI)!.stringValue + " dBm"
        majorLabel.text = " "
        minorLabel.text = " "
        distanceLabel.text = " "
    }
    
    func searchModel(model: Model) -> Model {
        if let indexElement = ibeacons.firstIndex(where: { $0.uuid == model.uuid &&
            $0.major == model.major &&
            $0.minor == model.minor
        }) {
            return ibeacons[indexElement]
        } else {
            return model
        }
        
    }

}

