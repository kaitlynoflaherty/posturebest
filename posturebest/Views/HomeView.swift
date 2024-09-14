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
        ScrollView {
            VStack {
                Text("Home Page")
                    .font(.largeTitle)
                    .foregroundStyle(Color(hex: "#374663"))
                    .padding()
                
                Text(currentDate)
                    .font(.title2)
                // Shaded box section for image and info button
                VStack {
                    ZStack {
                        // Background box
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 350, height: 300)
                            .shadow(radius: 5)
                            .padding()
                        VStack {
                            Image("TorsoOutline")
                                .resizable() // Allows you to resize the image
                                .aspectRatio(contentMode: .fit) // Adjust content mode as needed (fit, fill, etc.)
                                .frame(width: 250, height: 250) // Adjust size as needed
                            HStack {
                                Spacer()
                                VStack {
                                    InfoButtonView(message: "This is a three-dimensional model of your torso, displaying areas of concern in your posture (red sensors).")
                                }
                            }
                        }
                    }
                }
                
                // Progress tracker (line graph)
                VStack {
                    Text("Progress Tracker")
                        .font(.headline)
                        .padding()
                    
                    LineChart()
                    
                    
                    Spacer()
                }
                .navigationTitle("Home")
                .background(Color.white.ignoresSafeArea())
            }
        }
    }
        
        struct HomeView_Previews: PreviewProvider {
            static var previews: some View {
                HomeView()
        }
    }
}
