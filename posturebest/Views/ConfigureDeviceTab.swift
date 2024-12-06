//
//  ConfigureDeviceTab.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/16/24.
//

import Foundation
import SwiftUI
import simd
import CoreBluetooth
import SceneKit

struct ConfigureDeviceTab: View {
    @StateObject private var bleManager = BLEManager()  // Use the existing BLEManager
    @State private var showErrorAlert = false
    @Binding var showHeader: Bool
    @State private var orientationData: [String: simd_quatf] = [:]  // Dictionary to store quaternions
    
    let vestConfigInfo = "Follow the steps to sync the Posture Vest to you app."
    let instructions = "1. Ensure your device is on and connected to the PostureBest app via bluetooth. \n2. Stand with your feet hip-width apart and toes pointing forward. \n3. Straighten back, neck and align shoulders to desired position. \n4. Hold position and press the configure button."
    let note = "Note: Please hold position for about 5 seconds while the device is being configured."
    let boneNames = ["LowerBack", "MidBack", "UpperBack", "RightShoulder", "LeftShoulder"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Welcome to Vest Configuration!")
                    .font(.headline)
                    .foregroundStyle(Color(hex: "#374663"))
                    .padding(.bottom, 10)
                    .onAppear {
                                    showHeader = false
                                }
                                .onDisappear {
                                    showHeader = true
                                }
                
                InfoButtonView(message: vestConfigInfo, buttonSize: 15, title: "Vest Configuration", color: Color(.blue)).offset(x: -20, y: -5)
            }
            
            Text(instructions)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color(hex: "#374663"))
                .padding(.bottom, 50)
            
            Text(note)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color(hex: "#374663"))
                .padding(.bottom, 50)
            
        }
        .padding()
        
        VStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, content: {
            Button("Configure") {
                // Check if the device is connected
                if let connectedPeripheral = bleManager.cbPeripheral {
                    // TODO: Add in code to save ideal orientation data
                } else {
                    showErrorAlert = true
                }
            }.buttonStyle(.bordered)
                .alert(isPresented: $showErrorAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text("Device not connected. Please make sure the Posture Vest is paired with your device."),
                        dismissButton: .default(Text("OK"))
                    )
                }
        })
    }
    
    
    struct ConfigureDeviceTab_Previews: PreviewProvider {
        @State static var showHeader = false
        static var previews: some View {
            ConfigureDeviceTab(showHeader: $showHeader)
        }
    }
    
}
