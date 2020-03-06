//
//  FirstWindow.swift
//  TestApp
//
//  Created by Булат Сунгатуллин on 04.03.2020.
//  Copyright © 2020 Булат Сунгатуллин. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class FirstWindow: UITableViewController {
    
    @IBOutlet weak var UUIDLabel: UILabel!
    @IBOutlet weak var majorLabel: UILabel!
    @IBOutlet weak var minorLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    
    private let controller = BeaconManager()
    private var defaultUUID = "0E1DFC63-1C6E-4E94-87A2-895A97267022"
    var modelArray = [Model]()
    var bleArray = [BleModel]()
    var centralManager: CBCentralManager?
    let myRefreshContoll = UIRefreshControl()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //Initialise CoreBluetooth Central Manager
        centralManager =  CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    fileprivate func coreLocationSetup() {
        controller.locationManager = CLLocationManager.init()
        controller.locationManager.delegate = self
        controller.locationManager.requestWhenInUseAuthorization()
        controller.startScanning(beaconRegion: controller.getBeaconRegion(uuid: defaultUUID))
    }
    
    fileprivate func barButtonSetup() {
        let setButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(setUUID))
        self.navigationItem.rightBarButtonItem = setButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Таттелеком iBeacons"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.refreshControl = myRefreshContoll
        myRefreshContoll.addTarget(self, action: #selector(refreshAction(_:)), for: .valueChanged)
        
        barButtonSetup()
        coreLocationSetup()
    }
    
    @objc private func refreshAction(_ sender: Any) {
        self.myRefreshContoll.beginRefreshing()
        startScanning(refreshControll: myRefreshContoll)
    }
    
    @objc func setUUID() {
        let alertController = UIAlertController(title: "Добавтье Beacon Region", message: "Введите UUID устройства", preferredStyle: .alert)
        
        var uuidTextField: UITextField!
        alertController.addTextField { textField in
            textField.placeholder = "UUID"
            textField.text = self.controller.defaultUUID
            uuidTextField = textField
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let alertAction = UIAlertAction(title: "OK", style: .default) { alert in
            
            if self.controller.checkValidUUID(uuidString: uuidTextField.text!) {
                self.controller.defaultUUID = uuidTextField.text!
                self.controller.startScanning(beaconRegion:
                               self.controller.getBeaconRegion(uuid: self.controller.defaultUUID!))
            } else {
                self.presentInvalidUUIDAlert()
            }
            
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func presentInvalidUUIDAlert() {
        let errorAlertController = UIAlertController(title: "Неверный формат UUID", message: "Повторите попытку", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel)
        errorAlertController.addAction(action)
        present(errorAlertController, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return modelArray.count
        } else {
            return bleArray.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell
            let sortedArray = self.controller.filterModelArray(array: modelArray)
            
            cell.UUIDLabel.text = "UUID: " + (sortedArray[indexPath.row].uuid).uuidString
            cell.majorLabel.text = "major: " + (sortedArray[indexPath.row].major).stringValue
            cell.minorLabel.text = "minor: " + (sortedArray[indexPath.row].minor).stringValue
            cell.rssiLabel.text = "rssi: " + String(sortedArray[indexPath.row].rssi)
            cell.proximityLabel.text = "Расстояние: " + String(sortedArray[indexPath.row].proximity)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bleCell", for: indexPath) as! BleDevicesTableViewCell
            if bleArray.isEmpty {
                return cell
            } else {
                cell.deviceNameLabel.text = "Устройство: " + (bleArray[indexPath.row].peripheral?.name ?? "Unknown")
                cell.powerDeviceLabel.text = "rssi: " + (bleArray[indexPath.row].lastRSSI!).stringValue + " dB"
                return cell
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 170
        } else {
            return 90
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let secondVC = self.storyboard?.instantiateViewController(identifier: "detailVC") as! SecondWindow
        let navController = UINavigationController(rootViewController: secondVC)
        
        if indexPath.section == 0 {
            let sortedArray = self.controller.filterModelArray(array: modelArray)
            secondVC.beconModel = sortedArray[indexPath.row]
            secondVC.typeDevice = "iBeacon"
            secondVC.instanseOfAllVC = self
            self.navigationController!.present(navController, animated: true, completion: nil)
        } else {
            let bleModel = bleArray[indexPath.row]
            secondVC.typeDevice = "BLE"
            secondVC.bleModel = bleModel
            secondVC.instanseOfAllVC = self
            self.navigationController!.present(navController, animated: true, completion: nil)
        }
    }

}

