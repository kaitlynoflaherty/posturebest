//
//  UserProfileView.swift
//  posturebest
//
//  Created by Kaitlyn O’Flaherty on 9/4/24.
//

import Foundation
import SwiftUI

struct UserProfileView: View {
    var body: some View {
        VStack {
            Text("User Profile Page")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .navigationTitle("Profile")
        .background(Color.cyan.opacity(0.1).ignoresSafeArea())
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
