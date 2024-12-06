import Foundation
import SwiftUI
import simd
import CoreBluetooth
import SceneKit

struct ConfigureDeviceTab: View {
    @EnvironmentObject var bleManager: BLEManager  // Use the existing BLEManager
    @State private var showErrorAlert = false
    @Binding var showHeader: Bool
    @State private var orientationData: [String: simd_quatf] = [:]  // Dictionary to store quaternions
    
    var sensorDataProcessor = SensorDataProcessor()  // Use the existing SensorDataProcessor
    
    let vestConfigInfo = "Follow the steps to sync the Posture Vest to you app."
    let instructions = "1. Ensure your device is on and connected to the PostureBest app via bluetooth. \n2. Stand with your feet hip-width apart and toes pointing forward. \n3. Straighten back, neck and align shoulders to desired position. \n4. Hold position and press the configure button."
    let note = "Note: Please hold position for about 5 seconds while the device is being configured."
    let boneNames = ["LowerBack", "MidBack", "UpperBack", "RightShoulder", "LeftShoulder"]
    
    var body: some View {
        VStack {
            // Header section (no gray background)
            Text("Vest Configuration")
                .font(.largeTitle)
                .foregroundStyle(Color(hex: "#374663"))
                .frame(maxWidth: .infinity, alignment: .center)
                .onAppear {
                    showHeader = false // Hide the header when this screen appears
                }
                .onDisappear {
                    showHeader = true // Show the header when leaving this screen
                }
                .padding() // Optional padding for better spacing
            
            // Content section with light gray background (below the header)
            VStack(alignment: .leading, spacing: 15) {
                // Instructions section
                HStack {
                    Text("Instructions to configure:")
                        .font(.headline)
                        .foregroundStyle(Color(hex: "#374663"))
                        .padding(.bottom, 10)
                    InfoButtonView(message: vestConfigInfo, buttonSize: 15, title: "Vest Configuration", color: Color(.blue))
                        .offset(x: -20, y: -5)
                }
                
                // Detailed instructions
                Text(instructions)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color(hex: "#374663"))
                    .padding(.bottom, 50)
                
                // Note about configuration process
                Text(note)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color(hex: "#374663"))
                    .padding(.bottom, 50)
            }

            // Configure button
            Button("Configure") {
                // Check if the device is connected
                if let _ = bleManager.cbPeripheral {
                    showErrorAlert = false
                    // Capture the ideal orientation data
                    sensorDataProcessor.captureIdealOrientationData(from: sensorDataProcessor)
                } else {
                    showErrorAlert = true
                }
            }
            .buttonStyle(.bordered)
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text("Device not connected. Please make sure the Posture Vest is paired with your device."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding(.top)
        .onAppear {
            // Start scanning if necessary
            if bleManager.isSwitchedOn {
                bleManager.startScanning()
            }
        }
        .padding() // Optional padding to add some space around the content
    }
}

struct ConfigureDeviceTab_Previews: PreviewProvider {
    @State static var showHeader = false
    static var previews: some View {
        ConfigureDeviceTab(showHeader: $showHeader)
            .environmentObject(BLEManager()) // Provide the BLEManager object for preview
    }
}
