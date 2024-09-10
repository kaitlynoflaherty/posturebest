//
//  ConfigurationsView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/4/24.
//

import Foundation
import SwiftUI

struct ConfigurationsView: View {
    @State private var selectedOption: String = "Vest Config" // Initial selected value
       @State private var userInput: String = "" // User input
       
       let options = ["Vest Config", "Feedback", "Option 3"]
    var body: some View {
        VStack {
            Text("Configurations")
                .font(.largeTitle)
                .padding()
            // Dropdown menu (Picker)
            Picker("Select an option", selection: $selectedOption) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle()) // You can use different styles like .wheel or .segmented
            .padding()
            
            Text("Vest Configuration")
                        
            // Number input (TextField)
            TextField("Enter a number", text: $userInput)
                .keyboardType(.numberPad) // This sets the keyboard to number pad
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                        
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
