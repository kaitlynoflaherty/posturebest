//
//  ConfigurationsView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/4/24.
//

import Foundation
import SwiftUI

struct ConfigurationsView: View {
    @State private var selectedOption: String = "Configure Device"
    @State private var userInput: String = ""
       
    let options = ["Configure Device", "Configure Feedback"]
    
    var body: some View {
        VStack {
            Text("Configurations")
                .font(.largeTitle)
                .padding()
            
            Picker("Select an option", selection: $selectedOption) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedOption == "Configure Device" {
                // option for additional devices?
                Text("Vest Configuration")
                
                // add instructions and context
                // PT stuff for good posture
                // sync posture button
                // timer and completion status
                            
                TextField("Enter a number", text: $userInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            } else {
                Text("Feedback and Reminders")
                            
                TextField("Enter a number", text: $userInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
                        
            Spacer()
        }
        .navigationTitle("Configurations")
        .background(Color.white.ignoresSafeArea())
    }
}

struct ConfigurationsView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationsView()
    }
}
