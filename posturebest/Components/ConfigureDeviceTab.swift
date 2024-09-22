//
//  ConfigureDeviceTab.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/16/24.
//

import Foundation
import SwiftUI

struct ConfigureDeviceTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Welcome to Vest Configuration!")
                .font(.headline)
                .foregroundStyle(Color(hex: "#374663"))
                .padding(.bottom, 10)
            // add i hover next to vest config
            
            Text("1. Ensure your device is on and connected to the      PostureBest app via bluetooth. \n2. Stand with your feet hip-width apart and toes pointing forward. \n3. Straighten back, neck and align shoulders to desired position. \n4. Hold position and press the configure button.")
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color(hex: "#374663"))
                .padding(.bottom, 50)
            
            Text("Note: Please hold position for about 5 seconds while the device is being configured.")
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

