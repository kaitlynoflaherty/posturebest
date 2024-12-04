//
//  ConfigureAlertsTab.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/16/24.
//

//import Foundation
//import SwiftUI
//
//struct ConfigureAlertsTab: View {
//    @State private var selectedTime: String = "0:00"
//    @State private var standingFreqState: String = "15"
//    @State private var postureFreqState: String = "5"
//    let postureOpts = ["5", "10", "15", "20", "25", "30"]
//    let postureInfo = "This configuration will set how often the vest will alert you that your posture is not optimal."
//    let standingInfo = "This configuration will set how often the vest will alert you to stand up to improve movement throughout the day."
//        
//    // Stnading reminders in hours and minutes
//    let hours = Array(0...5).map { String($0) }
//    let minutes = ["00", "15", "30", "45"]
//    
//    // Combines hours and minutes into one array of options
//    private var timeOptions: [String] {
//        return hours.flatMap { hour in
//            minutes.map { minute in
//                "\(hour):\(minute)"
//            }
//        }
//    }
//    
//    
//    var body: some View {
//        VStack {
//            HStack {
//                Text("Standing Reminder Frequency (hours)")
//                    .font(.headline)
//                    .foregroundStyle(Color(hex: "#374663"))
//                    .padding(.top, 20)
//
//                InfoButtonView(message: standingInfo, buttonSize: 15, title: "Standing Reminders", color: Color(.blue)).offset(x: -30, y: 20)
//                
//                
//                Picker("Select Time", selection: $selectedTime) {
//                    ForEach(timeOptions, id: \.self) { time in
//                        Text(time).tag(time)
//                    }
//                }
//                .pickerStyle(WheelPickerStyle())
//                .frame(height: 100).frame(width: 100)
//                
//                
//            }.padding(.top, 0)
//            HStack {
//                Text("Posture Reminder \nFrequency (mins)")
//                    .font(.headline)
//                    .foregroundStyle(Color(hex: "#374663"))
//                    .padding(.top, 20)
//               
//                InfoButtonView(message: postureInfo, buttonSize: 15, title: "Posture Reminders", color: Color(.blue)).offset(x: -27, y: 20)
//                
//                Picker("Select Frequency", selection: $postureFreqState) {
//                    ForEach(postureOpts, id: \.self) { option in
//                        Text(option).tag(option)
//                    }
//                }
//                .pickerStyle(WheelPickerStyle()).frame(height: 100).frame(width: 100).offset(x: 5)
//                
//            }.padding(.top, 0)
//            
//            Spacer()
//
//            HStack {
//                Button(action: {
//                    // action: reset to previous states
//                }) {
//                    Text("Cancel")
//                }
//                .buttonStyle(.bordered)
//
//                Button("Save Changes") {
//                    // action: save new states
//                }.buttonStyle(.borderedProminent)
//            }
//        }
//    }
//}

import Foundation
import SwiftUI

struct ConfigureAlertsTab: View {
    
    // Sample data for the chart: date keys and scores
    let chartData: [Date: (shoulderScore: Double, backScore: Double, spinalStraightness: Double)] = [
        Date().addingTimeInterval(-3600): (shoulderScore: 20, backScore: 25, spinalStraightness: 70),
        Date().addingTimeInterval(-7200): (shoulderScore: 30, backScore: 55, spinalStraightness: 20),
        Date().addingTimeInterval(-10800): (shoulderScore: 25, backScore: 20, spinalStraightness: 30),
        Date().addingTimeInterval(-14400): (shoulderScore: 40, backScore: 45, spinalStraightness: 20),
        
        // Data from yesterday (1 day ago)
        Date().addingTimeInterval(-86400): (shoulderScore: 60, backScore: 95, spinalStraightness: 40),
        Date().addingTimeInterval(-82800): (shoulderScore: 50, backScore: 55, spinalStraightness: 20),
        
        // Data from 2 days ago
        Date().addingTimeInterval(-172800): (shoulderScore: 90, backScore: 85, spinalStraightness: 70),
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                
                // Pass the chartData dictionary to the LineChart component
                LineChart(scores: chartData) // Using the data dictionary here
                
                Spacer(minLength: 20)
                
                // Add more content here if needed
            }
            .padding()
        }
        .navigationTitle("Home")
        .background(Color.white.ignoresSafeArea())
    }
}

struct ConfigureAlertsTab_Previews: PreviewProvider {
    static var previews: some View {
        ConfigureAlertsTab()
    }
}
