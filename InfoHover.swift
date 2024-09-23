//
//  InfoHover.swift
//  posturebest
//
//  Created by Madeline Coco on 9/14/24.
//

import SwiftUI

struct InfoButtonView: View {
    let message: String
    let buttonSize: CGFloat
    let title: String
    @State private var showingAlert = false

    var body: some View {
        Button(action: {
            showingAlert = true
        }) {
            Image(systemName: "info.circle")
                .font(.system(size: buttonSize))
                .foregroundColor(.blue)
                .padding()
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(title),
                message: Text(message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
