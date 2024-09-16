//
//  ConfigureAlertsTab.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/16/24.
//

import Foundation
import SwiftUI

struct ConfigureAlertsTab: View {
    @State private var selectedTime: String = "0:00"
    @State private var standingFreqState: String = "15"
    @State private var postureFreqState: String = "5"
    let postureOpts = ["5", "10", "15", "20", "25", "30"]
        
    // Stnading reminders in hours and minutes
    let hours = Array(0...5).map { String($0) }
    let minutes = ["00", "15", "30", "45"]
    
    // Combines hours and minutes into one array of options
    private var timeOptions: [String] {
        return hours.flatMap { hour in
            minutes.map { minute in
                "\(hour):\(minute)"
            }
        }
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Text("Standing Reminder Frequency (hours)")
                    .font(.headline)
                    .foregroundStyle(Color(hex: "#374663"))
                    .padding(.top, 20)
                // add i hover
                
                Picker("Select Time", selection: $selectedTime) {
                    ForEach(timeOptions, id: \.self) { time in
                        Text(time).tag(time)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 100).frame(width: 100)
                
                
            }.padding(.top, 0)
            HStack {
                Text("Posture Reminder Frequency (mins)")
                    .font(.headline)
                    .foregroundStyle(Color(hex: "#374663"))
                    .padding(.top, 20)
                // add i hover
                
                Picker("Select Frequency", selection: $postureFreqState) {
                    ForEach(postureOpts, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(WheelPickerStyle()).frame(height: 100).frame(width: 100)
                
            }.padding(.top, 0)
            
            Spacer()

            HStack {
                Button("Cancel") {
                    // action: reset to previous states
                }.buttonStyle(.bordered)
                Button("Save Changes") {
                    // action: save new states
                }.buttonStyle(.borderedProminent)
            }
        }
    }
}

struct ConfigureAlertsTab_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureAlertsTab()
    }
}
