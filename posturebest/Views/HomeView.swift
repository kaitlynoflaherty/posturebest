//
//  HomeView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/4/24.
//

import Foundation
import SwiftUI

struct HomeView: View {
    // Create a date formatter
        private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none // option to add time
            return formatter
        }
        
        // Get the current date
        private var currentDate: String {
            dateFormatter.string(from: Date())
        }
    
    var body: some View {
        VStack {
            Text("Home Page")
                .font(.largeTitle)
                .foregroundStyle(Color(hex: "#374663"))
                .padding()
            
            Text(currentDate)
                .font(.title2)
            
            Image("TorsoOutline")
                .resizable() // Allows you to resize the image
                .aspectRatio(contentMode: .fit) // Adjust content mode as needed (fit, fill, etc.)
                .frame(width: 300, height: 300) // Adjust size as needed
                .padding()
            HStack {
                Spacer()
                Image(systemName: "battery.50") // SF Symbol for fully charged battery
                    .font(.system(size: 30)) // Adjust size as needed
                    .foregroundColor(.blue) // Adjust color as needed
                    .padding()
            }
            
            Spacer()
        }
        .navigationTitle("Home")
        .background(Color.white.ignoresSafeArea())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
