//
//  HomeView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/4/24.
//

import Foundation
import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Text("Home Page")
                .font(.largeTitle)
                .foregroundStyle(Color(hex: "#374663"))
                .padding()
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
