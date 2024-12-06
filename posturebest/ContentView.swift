//
//  ContentView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 8/21/24.

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var bleManager = BLEManager() // StateObject to initialize BLEManager
    @State private var showAlert = false

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
                    Label("Metrics", systemImage: "ruler")
                }

            UserProfileView(showAlert: $showAlert)
                .environmentObject(bleManager)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        // Show the alert at the root level (ContentView)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Time to Fix Your Posture!"),
                message: Text("You have had poor posture for the past 30 minutes."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
