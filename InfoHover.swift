//
//  InfoHover.swift
//  posturebest
//
//  Created by Madeline Coco on 9/14/24.
//

import SwiftUI

struct InfoButtonView: View {
    let message: String
    @State private var showingAlert = false

    var body: some View {
        Button(action: {
            showingAlert = true
        }) {
            Image(systemName: "info.circle")
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .padding()
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Description"),
                message: Text(message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
