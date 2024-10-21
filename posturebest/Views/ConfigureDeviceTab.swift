//
//  ConfigureDeviceTab.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/16/24.
//

import Foundation
import SwiftUI

struct ConfigureDeviceTab: View {
    let vestConfigInfo = "Follow the steps to sync the Posture Vest to you app."
    let instructions = "1. Ensure your device is on and connected to the PostureBest app via bluetooth. \n2. Stand with your feet hip-width apart and toes pointing forward. \n3. Straighten back, neck and align shoulders to desired position. \n4. Hold position and press the configure button."
    let note = "Note: Please hold position for about 5 seconds while the device is being configured."
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Welcome to Vest Configuration!")
                .font(.headline)
                .foregroundStyle(Color(hex: "#374663"))
                .padding(.bottom, 10)
                
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
                // Save configuration data to measure other points against
            }.buttonStyle(.bordered)
        })
    }
}

struct ConfigureDeviceTab_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureDeviceTab()
    }
}

