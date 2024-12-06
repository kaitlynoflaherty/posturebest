//
//  UserProfileView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/4/24.
//

import Foundation
import SwiftUI
import UserNotifications

struct UserProfileView: View {
    @Binding var showAlert: Bool

    @State private var showHeader: Bool = true
    @State private var isToggled = isNotifsToggled
    @State private var postureScore = score
    @State private var timer: Timer?
    
    @State private var showHeader = true
    @StateObject private var bleManager = BLEManager()
    let minScoreThreshold: Float = 0.5
    var deviceName = "PTSRBEST"

    var body: some View {
        VStack {
        if (showHeader) {
            Text("Settings")
                .font(.largeTitle)
                .foregroundStyle(Color(hex: "#374663"))
                .padding()
            }
            
            NavigationView {
                List {
                    Section(header: Text("My Device")) {
                        NavigationLink(destination: BluetoothDevicesView(showHeader: $showHeader)) {
                            Text(deviceName)
                        }
                    }
                    
                    Section {
                        NavigationLink(destination: BluetoothDevicesView(showHeader: $showHeader)) {
                            Text("Connect to Bluetooth Device")
                        }
                        NavigationLink(destination: ConfigureDeviceTab(showHeader: $showHeader)) {
                            Text("Vest Configuration")
                        }

                        Toggle("Push Notifications", isOn: $isToggled)
                            .onChange(of: isToggled) {
                                if isToggled {
                                    enableNotifications()
                                } else {
                                    disableNotifications()
                                }
                            }
                    }
                    
                }
            }
           
            Spacer()
        }
        .navigationTitle("Profile")
        .onAppear {
           requestNotificationPermission()
            startTimer()
       }
    }
    // Request permission for notifications
        func requestNotificationPermission() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if granted {
                    print("Notification permission granted.")
                } else {
                    print("Notification permission denied.")
                }
            }
        }

        // Enable notifications when toggle is ON
        func enableNotifications() {
            print("Notifications Enabled.")
        }

        // Disable notifications when toggle is OFF
        func disableNotifications() {
            print("Notifications Disabled.")
        }
    
        func startTimer() {
            print("timer started")
            timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
                checkThreshold()
            }
        }

        func stopTimer() {
            timer?.invalidate()
            timer = nil
        }

        // Check if the "bad" value exceeds the threshold and send a notification if so
        func checkThreshold() {
            if isToggled && postureScore <= minScoreThreshold {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 300) {
                    showAlert = true
                    sendNotification()
//                    isToggled = false
//                }
            }
        }

        // Function to send a local notification
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time to Fix Your Posture!"
        content.body = "You have had poor posture for the past 30 minutes."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "badThresholdNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error)")
            } else {
                print("Notification sent successfully.")
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self // Set the delegate
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }

        return true
    }
    
    // Handle notifications when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification even when the app is in the foreground
        completionHandler([.alert, .badge, .sound]) // Use correct presentation options here
    }
    
    // Other methods for background notifications if needed
}

//struct UserProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserProfileView()
//    }
//}
