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
    
    // Sample data for chart
    
    // TODO: Add in data pulled per minute to calculate score
    let chartData: [ChartData] = [
        ChartData(x: 1, y: 10),
        ChartData(x: 2, y: 20),
        ChartData(x: 3, y: 15),
        ChartData(x: 4, y: 25),
        ChartData(x: 5, y: 30)
    ]
    
    var body: some View {
        VStack {
            Text("Progress Tracker")
                .font(.headline)
                .padding()
            
            LineChart(data: chartData)
            
            Spacer(minLength: 20)
            
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
