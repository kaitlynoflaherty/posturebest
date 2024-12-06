//
//  BluetoothDevicesView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 10/3/24.
//

import Foundation
import SwiftUI
import CoreBluetooth

func rssiColor(for rssi: Int?) -> Color {
    guard let rssiValue = rssi else { return .gray }

    switch rssiValue {
    case let x where x >= -70:
        return .green
    case let x where x >= -80:
        return .yellow
    case let x where x < -80:
        return .red
    default:
        return .gray
    }
}

struct BluetoothDevicesView: View {
    @EnvironmentObject var bleManager: BLEManager
    @Binding var showHeader: Bool

    var body: some View {
        VStack (spacing: 10) {
            Text("Bluetooth Devices")
                .font(.largeTitle)
                .foregroundStyle(Color(hex: "#374663"))
                .frame(maxWidth: .infinity, alignment: .center)
                .onAppear {
                                showHeader = false
                            }
                            .onDisappear {
                                showHeader = true
                            }

            List(bleManager.periperals) { peripheral in
                if peripheral.name != "Unknown" {
                    HStack {
                        Text(peripheral.name)
                            .foregroundStyle(Color(hex: "#374663"))
                        Spacer()
                        
                        // rssi strength indicator
                        Circle()
                            .fill(rssiColor(for: peripheral.rssi))
                            .frame(width: 5, height: 5)
                        
                        
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
                    bleManager.disconnect()
                }) {
                    Text("Disconnect")
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
    @State static var showHeader = false
    static var previews: some View {
        BluetoothDevicesView(showHeader: $showHeader)
    }
}
