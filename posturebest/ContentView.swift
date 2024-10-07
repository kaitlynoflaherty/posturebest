//
//  ContentView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 8/21/24.
//

// filter out unknown names
// disconnect option
// add rssi strngth

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            ConfigurationsView(deviceName: "placeholder")
                .tabItem {
                    Label("Configurations", systemImage: "gear")
                }
            
            BluetoothDevicesView()
                .tabItem {
                    Label("Bluetooth", systemImage: "wifi")
                }

            UserProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
