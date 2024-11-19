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
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Home Page")
                    .font(.largeTitle)
                    .foregroundStyle(Color(hex: "#374663"))
                    .padding()
                
                Text(currentDate)
                    .font(.title2)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "#374663"))
                        .frame(width: 350, height: 500)
                        .shadow(radius: 5)
                        .padding()
                    VStack {
                        Model3DView()
                            .frame(width: 250, height: 400)
                        HStack {
                            VStack {
                                InfoButtonView(message: "This is a three-dimensional model of your torso, displaying areas of concern in your posture (red sensors).", buttonSize: 30, title: "Description", color: Color(.gray)).offset(x: 135, y: 10)
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView()
        }
    }
}
