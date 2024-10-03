//
//  BluetoothDevicesView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 10/3/24.
//

import Foundation
import SwiftUI
import CoreBluetooth

struct BluetoothDevicesView: View {
    @StateObject var bleManager = BLEManager()
    var body: some View {
        VStack (spacing: 10) {
            Text("Bluetooth Devices")
                .font(.largeTitle)
                .foregroundStyle(Color(hex: "#374663"))
                .frame(maxWidth: .infinity, alignment: .center)

            List(bleManager.periperals) { peripheral in
                HStack {
                    Text(peripheral.name)
                        .foregroundStyle(Color(hex: "#374663"))
                    Spacer()
                    Text(String(peripheral.rssi))
                        .foregroundStyle(Color(hex: "#374663"))
                    Button(action: {
                        bleManager.connect(to: peripheral)
                    }) {
                        if bleManager.connectedPeripheralUUID == peripheral.id {
                            Text("Connected")
                                .foregroundColor(.green)
                        } else {
                            Text("Connect")
                        }
                    }
                }
            }.frame(height: UIScreen.main.bounds.height / 2)
            
            Spacer()
            
            Text("STATUS")
                .font(.headline)
                .foregroundStyle(Color(hex: "#374663"))
            
            if bleManager.isSwitchedOn {
                Text("Bluetooth is switched on").foregroundColor(.green)
            } else {
                Text("Bluetooth is NOT switched on").foregroundColor(.red)
            }
            
            Spacer()
            
            VStack(spacing: 25) {
                Button(action: {
                    bleManager.startScanning()
                }) {
                    Text("Start scanning")
                        .buttonStyle(BorderedProminentButtonStyle())
                }
                
                Button(action: {
                    bleManager.stopScanning()
                }) {
                    Text("Stop scanning")
                        .buttonStyle(BorderedProminentButtonStyle())
                }
            }.padding()
            
            Spacer()
        }.onAppear {
            if bleManager.isSwitchedOn {
                bleManager.startScanning()
            }
        }
    }
}

struct BluetoothDevicesView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothDevicesView()
    }
}
