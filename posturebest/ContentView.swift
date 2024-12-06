//
//  ContentView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 8/21/24.

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var bleManager = BLEManager() // StateObject to initialize BLEManager
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(bleManager)
                .tabItem {
                    Label("Home", systemImage: "house")
                }


            MetricsView(deviceName: "Demo")
                .environmentObject(bleManager)
                .tabItem {
                    Label("Configurations", systemImage: "gear")
                }

            UserProfileView()
                .environmentObject(bleManager)
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
