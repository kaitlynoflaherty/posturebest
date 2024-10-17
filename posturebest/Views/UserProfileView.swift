//
//  UserProfileView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/4/24.
//

import Foundation
import SwiftUI

struct UserProfileView: View {
    // add username
    // add device name
    
    @State private var showHeader = true
    var body: some View {
        VStack {
        if (showHeader) {
            Text("User Profile Page")
                .font(.largeTitle)
                .foregroundStyle(Color(hex: "#374663"))
                .padding()
            
                HStack{
                    Circle()
                        .fill()
                        .frame(width: 60, height: 60)
                    
                    Text("username")
                        .font(.title3)
                }
                .foregroundStyle(Color(hex: "#374663"))
                .offset(x: -100)
            }
            
            NavigationView {
                List {
//                    Section(header: Text("My Device")) {
//                        NavigationLink(destination: BluetoothDevicesView(showHeader: $showHeader)) {
//                            Text("deviceName || disconnected")
//                        }
//                    }

                    Section() {
                        NavigationLink(destination: BluetoothDevicesView(showHeader: $showHeader)) {
                            Text("Connect to Bluetooth Device")
                        }
//                        NavigationLink(destination: BluetoothDevicesView(showHeader: $showHeader)) {
//                            Text("Account Information")
//                        }
//                        NavigationLink(destination: BluetoothDevicesView(showHeader: $showHeader)) {
//                            Text("User Settings")
//                        }
                    }
                    
                }
            }
           
            Spacer()
        }
        .navigationTitle("Profile")
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
