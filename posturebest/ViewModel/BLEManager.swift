//
//  BLEManager.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 10/2/24.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var myCentral: CBCentralManager!
    @Published var isSwitchedOn = false
    @Published var periperals = [Peripheral]() // stores discovered periphs
    @Published var connectedPeripheralUUID: UUID?
    var cbPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        myCentral = CBCentralManager(delegate: self, queue: nil)
    }
    
    // Delegate method called when state of central manager updated
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        isSwitchedOn = central.state == .poweredOn
        if isSwitchedOn {
            startScanning()
        } else {
            stopScanning()
        }
    }
    
    // Delegate method for when peripheral discovered
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let newPeripheral = Peripheral(id: peripheral.identifier, name: peripheral.name ?? "Unknown", rssi: RSSI.intValue)
        
        // Add peripheral to list if not there
        if !periperals.contains(where: {$0.id == newPeripheral.id}) {
            DispatchQueue.main.async{
                self.periperals.append(newPeripheral)
            }
        }
    }
    
    func startScanning() {
        print("Scanning for devices...")
        // Not scanning for specific services
        myCentral.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScanning() {
        print("Scanning stopped.")
        myCentral.stopScan()
    }
    
    func connect(to peripheral: Peripheral) {
        guard let cbPeripheralTemp = myCentral.retrievePeripherals(withIdentifiers: [peripheral.id]).first
        else {
            print("Peripheral not found for connection")
            return
        }
        
        // setting the UUID
        connectedPeripheralUUID = cbPeripheralTemp.identifier
        cbPeripheralTemp.delegate = self
        
        cbPeripheral = cbPeripheralTemp
        
        myCentral.connect(cbPeripheral!, options: nil)
    }
    
    // Delegate method for when peripheral is connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Successfully connected to \(peripheral.name ?? "Unknown")")
        
        // discover services on the connected peripheral
        peripheral.discoverServices(nil)
    }
    
    // Delegate method for failed connection
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown"): \(error?.localizedDescription ?? "No error information")")
        if peripheral.identifier == connectedPeripheralUUID {
            connectedPeripheralUUID = nil
        }
    }
    
    // Delegate method for diconnection
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "Unknown")")
        if peripheral.identifier == connectedPeripheralUUID {
            connectedPeripheralUUID = nil
        }
    }
    
    // Delegate method for when services are discovered on a peripheral
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                print("Discovered service: \(service)")
                peripheral.discoverCharacteristics(nil, for: service) // Discover characteristics for service
            }
        }
    }
    
    // Delegate method for when characteristics discovered on service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.properties.contains(.read) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        peripheral.readValue(for: characteristic)
                    }
                    print("Discovered characteristic: \(characteristic)")
                }
            }
        }
    }
    
    // Delegate method to update the value field for a characteristic
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error reading characteristic: \(error.localizedDescription)")
            return
        }
        
        if let value = characteristic.value {
            let bytes = [UInt8](value)
            print("Characteristic Value: \(bytes)")
        } else {
            print("Characteristic value is nil.")
        }
    }
}
