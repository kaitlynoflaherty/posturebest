//
//  HomeView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/4/24.
//

import Foundation
import SwiftUI

struct HomeView: View {
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }
    
    private var currentDate: String {
        dateFormatter.string(from: Date())
    }
    
    // Sample data for chart
    let chartData: [ChartData] = [
        ChartData(x: 1, y: 10),
        ChartData(x: 2, y: 20),
        ChartData(x: 3, y: 15),
        ChartData(x: 4, y: 25),
        ChartData(x: 5, y: 30)
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Home Page")
                    .font(.largeTitle)
                    .foregroundStyle(Color(hex: "#374663"))
                    .padding()
                
                Text(currentDate)
                    .font(.title2)
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 350, height: 300)
                            .shadow(radius: 5)
                            .padding()
                        VStack {
                            Image("TorsoOutline")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 250, height: 250)
                            HStack {
                                Spacer()
                                VStack {
                                    InfoButtonView(message: "This is a three-dimensional model of your torso, displaying areas of concern in your posture (red sensors).", buttonSize: 30, title: "Description")
                                }
                            }
                        }
                    }
                }
                
                VStack {
                    Text("Progress Tracker")
                        .font(.headline)
                        .padding()
                    
                    LineChart(data: chartData)
                    
                    
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
