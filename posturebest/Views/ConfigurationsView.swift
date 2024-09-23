//
//  ConfigurationsView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/4/24.
//

import SwiftUI

struct ConfigurationsView: View {
    let deviceName: String
    let tabOptions = ["Configure Alerts", "Configure Device"]
    @State private var tabState: String = "Configure Alerts"
    
    var body: some View {
        VStack {
            VStack {
                Text("Configurations")
                    .font(.largeTitle)
                    .foregroundStyle(Color(hex: "#374663"))
                    .padding()
                
                Text("Configure \(deviceName)")
                    .foregroundStyle(Color(hex: "#374663"))
                
                Picker("Select an option", selection: $tabState) {
                    ForEach(tabOptions, id: \.self) { option in
                        Text(option).tag(option).foregroundStyle(Color(hex: "#374663"))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            
            VStack() {
                if tabState == "Configure Device" {
                    ConfigureDeviceTab()
                } else {
                    ConfigureAlertsTab()
                }
                
                Spacer()
            }
            .navigationTitle("Configurations")
            .background(Color.white.ignoresSafeArea())
        }
    }
}

struct ConfigurationsView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationsView(deviceName: "placeholder")
    }
}
