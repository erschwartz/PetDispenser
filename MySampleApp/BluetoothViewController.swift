//
//  BluetoothViewController.swift
//  MySampleApp
//
//  Created by Admin on 4/29/17.
//
//

import Foundation
import UIKit
import CoreBluetooth

class BluetoothViewController : UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITextFieldDelegate {
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityScreen: UILabel!
    
    @IBOutlet weak var networkPasswordLabel: UITextField!
    @IBOutlet weak var networkNameLabel: UITextField!
    var manager: CBCentralManager!
    var conn: CBPeripheral!
    var char: CBCharacteristic!
    private let UuidSerialService = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    private let UuidTx =            "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    private let UuidRx =            "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    
    var user: User?
    var pet: Pet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        
        activityLabel.isHidden = true
        activityScreen.isHidden = true
        activityIndicator.isHidden = true
    }
    
    private func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("Found peripheral with name \(peripheral.name)")
        if (peripheral.name == "raspberrypi") {
            self.conn = peripheral
            self.conn.delegate = self
            manager.stopScan()
            manager.connect(self.conn, options: nil)
            print("CONNECTED")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let servicePeripheral = peripheral.services! as [CBService]!{
            for service in servicePeripheral{
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Discovered characteristics")
        sendData(peripheral, service)
    }
    
    private func sendData(_ peripheral: CBPeripheral, _ service: CBService) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                // Tx:
                if characteristic.uuid == CBUUID(string: UuidTx) {
                    print("Tx char found: \(characteristic.uuid)")
                    let data = NSData(base64Encoded: networkPasswordLabel.text!, options: [])
                    peripheral.writeValue(data as! Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                }
                
                // Rx:
                if characteristic.uuid == CBUUID(string: UuidRx) {
                    print("Rx char found: \(characteristic.uuid)")
                    peripheral.setNotifyValue(true, for: characteristic)
                    let data = NSData(base64Encoded: networkPasswordLabel.text!, options: [])
                    peripheral.writeValue(data as! Data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
                }
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch(central.state){
        case .poweredOn:
            manager.scanForPeripherals(withServices: nil, options:nil)
            print("Bluetooth is powered ON")
        case .poweredOff:
            print("Bluetooth is powered OFF")
        case .resetting:
            print("Bluetooth is resetting")
        case .unauthorized:
            print("Bluetooth is unauthorized")
        case .unknown:
            print("Bluetooth is unknown")
        case .unsupported:
            print("Bluetooth is not supported")
        }
    }

    @IBAction func didSelectContinueBackground(_ sender: Any) {
        doContinue()
    }
    
    @IBAction func didSelectContinue(_ sender: Any) {
        doContinue()
    }
    
    func doContinue() {
        activityLabel.isHidden = false
        activityScreen.isHidden = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        sleep(3)
        
        performSegue(withIdentifier: "bluetoothContinue", sender: self)
        
        activityIndicator.stopAnimating()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? NewUserViewControllerFour {
            destinationViewController.user = user
            destinationViewController.pet = pet
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        activityLabel.isHidden = true
        activityScreen.isHidden = true
        activityIndicator.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func didSelectBackButton(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
